terraform {
  required_version = ">= 0.13.4"

  backend "s3" {
    encrypt = "true"
    bucket  = "dh-nerddays-terraform"
    key     = "infrastructure/infrastructure.tfstate"
    region  = "eu-central-1"
    profile = "dh-nerddays-demo"
  }
}

provider "aws" {
  profile = "dh-nerddays-demo"
  region  = "eu-central-1"
}
