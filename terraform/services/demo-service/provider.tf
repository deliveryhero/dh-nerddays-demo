terraform {
  required_version = "0.13.5"

  backend "s3" {
    encrypt = "true"
    bucket  = "dh-nerddays-terraform"
    key     = "services/demo-service.tfstate"
    region  = "eu-central-1"
    profile = "dh-nerddays-demo"
  }
}

provider "aws" {
  profile = "dh-nerddays-demo"
  region  = "eu-central-1"
}

provider "sops" {}

provider "mysql" {
  endpoint = local.mysql_provider.endpoint
  username = local.mysql_provider.username
  password = local.mysql_provider.password
}
