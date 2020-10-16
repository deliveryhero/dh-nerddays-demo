#################################
# S3 Bucket for Terraform State #
#################################
module "terraform-s3-bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "1.15.0"

  bucket = "dh-nerddays-terraform"
  acl    = "private"
}

#####################
# DNS Configuration #
#####################
module "atlantis-route53-zone" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "1.2.0"

  zones = {
    "atlantis-dh-nerddays-demo.com" = {
      comment = "Atlantis Domain for DH NerdDays Demo"
      tags = local.tags
    }
  }
}

##########
# DH IPs #
##########
module "dh-ips" {
  source = "git::ssh://git@github.com/deliveryhero/dh-gcs-terraform-tools.git//ip-whitelist-module"
  token  = data.sops_file.atlantis-secrets.data["dh-ips.token"]
}

####################
# Atlantis Service #
####################
module "atlantis" {
  source  = "terraform-aws-modules/atlantis/aws"
  version = "2.24.0"

  name = "atlantis"

  # VPC
  cidr            = "10.50.0.0/16"
  azs             = data.aws_availability_zones.azs.names
  private_subnets = [for index, az in data.aws_availability_zones.azs.names : cidrsubnet("10.50.0.0/16", 8, (index + 1))]
  public_subnets  = [for index, az in data.aws_availability_zones.azs.names : cidrsubnet("10.50.0.0/16", 8, (index + 101))]

  # ECS
  ecs_task_cpu    = 2000
  ecs_task_memory = 2048

  # DNS (without trailing dot)
  route53_zone_name = "atlantis-dh-nerddays-demo.com"

  # ALB access
  alb_ingress_cidr_blocks         = module.dh-ips.ipv4_cidr_blocks
  alb_logging_enabled             = true
  alb_log_bucket_name             = module.atlantis-access-log-bucket.this_s3_bucket_id
  alb_log_location_prefix         = "atlantis-alb"
  alb_listener_ssl_policy_default = "ELBSecurityPolicy-TLS-1-2-2017-01"

  allow_unauthenticated_access = false
  allow_github_webhooks        = true
  allow_repo_config            = true

  # Atlantis
  atlantis_github_user        = data.sops_file.atlantis-secrets.data["github.user"]
  atlantis_github_user_token  = data.sops_file.atlantis-secrets.data["github.token"]
  atlantis_repo_whitelist     = ["github.com/${data.sops_file.atlantis-secrets.data["github.organization"]}/*"]
  atlantis_allowed_repo_names = ["dh-nerddays-demo"]

  custom_environment_variables = [
    {
      name  = "ATLANTIS_WRITE_GIT_CREDS"
      value = "1"
    },
    {
      name  = "ATLANTIS_DEFAULT_TF_VERSION"
      value = "0.13.4"
    },
    {
      name  = "ATLANTIS_REPO_CONFIG"
      value = data.local_file.atlantis-config.content
    }
  ]

  tags = local.tags
}

################################################################################
# GitHub Webhooks
################################################################################

module "atlantis-github-repository-webhook" {
  source = "terraform-aws-modules/atlantis/aws//modules/github-repository-webhook"
  version = "2.24.0"

  github_organization = data.sops_file.atlantis-secrets.data["github.organization"]
  github_token        = data.sops_file.atlantis-secrets.data["github.token"]

  atlantis_allowed_repo_names = module.atlantis.atlantis_allowed_repo_names

  webhook_url    = module.atlantis.atlantis_url_events
  webhook_secret = module.atlantis.webhook_secret
}

################################################################################
# ALB Access Log Bucket + Policy
################################################################################

module "atlantis-access-log-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 1.9"

  bucket = "atlantis-access-logs-dh-nerddays"

  attach_policy = true
  policy        = data.aws_iam_policy_document.atlantis_access_log_bucket_policy.json

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  force_destroy = true

  tags = local.tags

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "all"
      enabled = true

      expiration = {
        days = 10
      }

      noncurrent_version_expiration = {
        days = 5
      }
    },
  ]
}

data "aws_iam_policy_document" "atlantis_access_log_bucket_policy" {
  statement {
    sid     = "LogsLogDeliveryWrite"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${module.atlantis-access-log-bucket.this_s3_bucket_arn}/*/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
        data.aws_elb_service_account.current.arn,
      ]
    }
  }

  statement {
    sid     = "AWSLogDeliveryWrite"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${module.atlantis-access-log-bucket.this_s3_bucket_arn}/*/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }

  statement {
    sid     = "AWSLogDeliveryAclCheck"
    effect  = "Allow"
    actions = ["s3:GetBucketAcl"]
    resources = [
      module.atlantis-access-log-bucket.this_s3_bucket_arn
    ]

    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
    }
  }
}
