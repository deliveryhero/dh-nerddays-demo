terraform {
  required_version = "0.13.5"

  backend "s3" {
    encrypt = "true"
    bucket  = "dh-nerddays-terraform"
    key     = "services/demo-service.tfstate"
    region  = "eu-central-1"
    profile = "dh-nerddays-demo"
  }

  required_providers {
    sops = {
      source = "carlpett/sops"
      version = "0.5.2"
    }
    mysql = {
      source  = "terraform-providers/mysql"
      version = "1.9.0"
    }
  }
}

provider "aws" {
  profile = "dh-nerddays-demo"
  region  = "eu-central-1"
}

provider "sops" {}

provider "mysql" {
  alias    = "demo-service"
  endpoint = format("%s:3306", module.aurora_mysql.this_rds_cluster_endpoint)
  username = data.sops_file.secrets.data["aurora-mysql.root-credentials.user"]
  password = data.sops_file.secrets.data["aurora-mysql.root-credentials.password"]
}
