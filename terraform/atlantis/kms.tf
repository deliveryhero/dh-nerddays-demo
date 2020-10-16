resource "aws_kms_key" "atlantis-kms-key" {
  description             = "KMS Key to encrypt Atlantis Secrets"
  policy                  = data.aws_iam_policy_document.atlantis-kms-key-policy.json
  deletion_window_in_days = 7

  tags = local.tags
}

resource "aws_kms_alias" "atlantis-kms-key-alias" {
  name          = "alias/atlantis"
  target_key_id = aws_kms_key.atlantis-kms-key.id
}


data "aws_iam_policy_document" "atlantis-kms-key-policy" {
  statement {
    sid     = "Allow the root user to manage the KMS key"
    actions = ["kms:*"]
    effect  = "Allow"
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid     = "Allow the Administrator Role to use the KMS key"
    actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
    effect  = "Allow"
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/FederatedAdministratorRole"]
    }
  }

  statement {
    sid     = "Allow Atlantis Role to use the KMS key"
    actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
    effect  = "Allow"
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [module.atlantis.task_role_arn]
    }
  }
}
