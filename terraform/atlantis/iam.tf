data "aws_iam_policy_document" "atlantis-extra-policy" {
  statement {
    sid    = "AccessToGithubSSHKeyParameter"
    effect = "Allow"

    resources = [ aws_ssm_parameter.atlantis-github-ssh-key-secret.arn ]

    actions = [
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
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
