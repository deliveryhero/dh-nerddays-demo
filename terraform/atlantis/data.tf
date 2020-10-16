data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "azs" {}

data "aws_elb_service_account" "current" {}

data "sops_file" "atlantis-secrets" {
  source_file = "./secrets.enc.yaml"
}
