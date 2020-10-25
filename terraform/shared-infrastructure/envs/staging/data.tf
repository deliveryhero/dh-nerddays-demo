data "aws_caller_identity" "current" {}

data "aws_availability_zones" "azs" {}

data "sops_file" "secrets" {
  source_file = "${path.module}/secrets.enc.yaml"
}

data "aws_route53_zone" "dh-nerddays-demo" {
  name = "dh-nerddays-demo.com"
}
