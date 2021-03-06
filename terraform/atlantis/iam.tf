data "aws_iam_policy_document" "atlantis-extra-policy" {
  statement {
    sid    = "AccessToTFStateS3Bucket"
    effect = "Allow"
    resources = [
      module.terraform-s3-bucket.this_s3_bucket_arn,
      "${module.terraform-s3-bucket.this_s3_bucket_arn}/*",
      module.atlantis-access-log-bucket.this_s3_bucket_arn,
      "${module.atlantis-access-log-bucket.this_s3_bucket_arn}/*"
    ]
    actions = ["s3:*"]
  }

  statement {
    sid    = "BuildServices"
    effect = "Allow"
    resources = ["*"]
    actions = [
        "acm:*",
        "cloudwatch:*",
        "dynamodb:CreateTable",
        "dynamodb:CreateGlobalTable",
        "dynamodb:DeleteTable",
        "dynamodb:UpdateTable",
        "dynamodb:UpdateGlobalTable",
        "dynamodb:UpdateGlobalTableSettings",
        "dynamodb:UpdateTimeToLive",
        "dynamodb:Describe*",
        "dynamodb:List*",
        "dynamodb:TagResource",
        "dynamodb:UntagResource",
        "ebs:*",
        "ec2:AllocateAddress",
        "ec2:AssociateAddress",
        "ec2:DescribeAddresses",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
        "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
        "ec2:Describe*",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:*Volume*",
        "ec2:*Instance*",
        "ec2:*Vpc*",
        "ec2:*Subnet*",
        "ec2:*Route*",
        "ec2:*KeyPair*",
        "ec2:*NatGateway*",
        "ec2:DescribeAvailabilityZones",
        "ec2:CreateInternetGateway",
        "ec2:AttachInternetGateway",
        "ec2:DisassociateAddress",
        "ec2:ReleaseAddress",
        "ec2:ModifyVpcAttribute",
        "ecs:*",
        "eks:*",
        "elasticache:*",
        "elasticfilesystem:CreateFileSystem",
        "elasticfilesystem:DeleteFileSystem",
        "elasticfilesystem:UpdateFileSystem",
        "elasticfilesystem:Describe*",
        "elasticfilesystem:CreateMountTarget",
        "elasticfilesystem:DeleteMountTarget",
        "elasticfilesystem:TagResource",
        "elasticfilesystem:UntagResource",
        "elasticloadbalancing:*",
        "es:*",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:CreatePolicy",
        "iam:CreateRole",
        "iam:DeletePolicy",
        "iam:DeleteRole",
        "iam:DeleteServiceLinkedRole",
        "iam:DeleteRolePolicy",
        "iam:GetOpenIDConnectProvider",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:GetUser",
        "iam:GetRole",
        "iam:GetRolePolicy",
        "iam:GetServiceLinkedRoleDeletionStatus",
        "iam:*InstanceProfile",
        "iam:ListInstanceProfilesForRole",
        "iam:ListAttachedRolePolicies",
        "iam:ListEntitiesForPolicy",
        "iam:ListPolicies",
        "iam:ListRolePolicies",
        "iam:ListRoleTags",
        "iam:ListRoles",
        "iam:PassRole",
        "iam:PutRolePolicy",
        "iam:CreateServiceLinkedRole",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:UpdateRole",
        "iam:UpdateRoleDescription",
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:Encrypt",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion",
        "kms:TagResource",
        "kms:UntagResource",
        "lambda:*Function",
        "lambda:*EventSourceMapping*",
        "lambda:TagResource",
        "lambda:UntagResource",
        "logs:*",
        "rds:*",
        "route53:ChangeResourceRecordSets",
        "route53:ChangeTagsForResource",
        "route53:CreateHostedZone",
        "route53:DeleteHostedZone",
        "route53:GetHostedZone",
        "route53:GetChange",
        "route53:ListHostedZones",
        "route53:ListHostedZonesByName",
        "route53:ListResourceRecordSets",
        "route53:ListTagsForResource",
        "route53:ListTagsForResources",
        "route53:UpdateHostedZoneComment",
        "secretsmanager:CreateSecret",
        "secretsmanager:UpdateSecret",
        "secretsmanager:DeleteSecret",
        "secretsmanager:DescribeSecret",
        "secretsmanager:TagResource",
        "secretsmanager:UntagResource",
        "secretsmanager:GetResourcePolicy",
        "sns:ConfirmSubscription",
        "sns:CreateTopic",
        "sns:DeleteTopic",
        "sns:GetSubscriptionAttributes",
        "sns:GetTopicAttributes",
        "sns:ListSubscriptions",
        "sns:ListSubscriptionsByTopic",
        "sns:ListTagsForResource",
        "sns:ListTopics",
        "sns:SetSubscriptionAttributes",
        "sns:SetTopicAttributes",
        "sns:Subscribe",
        "sns:TagResource",
        "sns:Unsubscribe",
        "sns:UntagResource",
        "sqs:AddPermission",
        "sqs:ChangeMessageVisibility",
        "sqs:CreateQueue",
        "sqs:DeleteQueue",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ListDeadLetterSourceQueues",
        "sqs:ListQueueTags",
        "sqs:ListQueues",
        "sqs:RemovePermission",
        "sqs:SetQueueAttributes",
        "sqs:TagQueue",
        "sqs:UntagQueue",
        "ssm:AddTagsToResource",
        "ssm:RemoveTagsFromResource",
        "ssm:ListTagsForResource",
        "ssm:DeleteParameter",
        "ssm:DeleteParameters",
        "ssm:DescribeParameters",
        "ssm:GetParameter*",
        "ssm:LabelParameterVersion",
        "ssm:PutParameter",
        "s3:GetObject",
        "s3:ListBucket",
    ]
  }
}

resource "aws_iam_policy" "atlantis-extra-policy" {
  name   = "atlantis-extra-policy"
  policy = data.aws_iam_policy_document.atlantis-extra-policy.json
}

resource "aws_iam_role_policy_attachment" "atlantis-extra-policy" {
  role       = module.atlantis.task_role_name
  policy_arn = aws_iam_policy.atlantis-extra-policy.arn
}
