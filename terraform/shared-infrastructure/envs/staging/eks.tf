data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "1.13.2"
}


###############
# EKS Cluster #
###############
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "12.2.0"
  cluster_name    = local.eks_cluster_name
  cluster_version = "1.17"
  subnets         = module.vpc.private_subnets
  enable_irsa     = true

  tags = merge(local.tags,
         {
           Kubernetes = true
         })

  vpc_id = module.vpc.vpc_id

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  node_groups = {
    workers-1 = {
      name             = "${local.eks_cluster_name}-workers-1"
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_type = "t3.medium"
      k8s_labels = {
        environment     = "demo"
        managed-worker  = "true"
      }
      additional_tags = {
        Name                                                  = "${local.eks_cluster_name}-workers-1"
        "k8s.io/cluster-autoscaler/enabled"                   = "true"
        "k8s.io/cluster-autoscaler/${local.eks_cluster_name}" = "owned"
      }
    }
  }

  map_roles    = [
    {
      rolearn  = data.sops_file.secrets.data["eks-roles.infra.role"]
      username = data.sops_file.secrets.data["eks-roles.infra.username"]
      groups   = [for group in yamldecode(data.sops_file.secrets.raw).eks-roles.infra.groups : group ]
    }
  ]
}

######################################
# Cluster Autoscaler IAM Permissions #
######################################
resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = aws_iam_policy.worker_autoscaling.arn
  role       = module.eks.worker_iam_role_name
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${module.eks.cluster_id}"
  description = "EKS worker node autoscaling policy for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.worker_autoscaling.json
  path        = "/eks/demo-cluster/"
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

###############################
# ExternalDNS IAM Permissions #
###############################
data "aws_iam_policy_document" "k8s_externaldns_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${module.eks.cluster_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:infra:external-dns"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "k8s_externaldns" {
  assume_role_policy = data.aws_iam_policy_document.k8s_externaldns_oidc.json
  name               = "k8s-external-dns"
  path               = "/kubernetes/"

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "k8s_externaldns" {
  policy_arn = aws_iam_policy.k8s_externaldns.arn
  role       = aws_iam_role.k8s_externaldns.name
}

resource "aws_iam_policy" "k8s_externaldns" {
  name_prefix = "k8s-external-dns"
  description = "AWS Role for Kubernetes External DNS"
  policy      = data.aws_iam_policy_document.k8s_externaldns.json
  path        = "/kubernetes/"
}

data "aws_iam_policy_document" "k8s_externaldns" {
  statement {
    sid     = "AllowUpdateRoute53Zone"
    effect  = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/Z061833026M6AGLS3ML64",
      "arn:aws:route53:::hostedzone/Z00425511KNMOW9YGLJLL"
    ]
  }

  statement {
    sid     = "ListAllRoute53Zones"
    effect  = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = ["*"]
  }
}
