terraform {
  required_version = "0.13.5"

  backend "s3" {
    encrypt = "true"
    bucket  = "terraform"
    key     = "staging/shared-infrastructure.tfstate"
    region  = "eu-west-1"
    profile = "staging"
  }
}

provider "aws" {
  profile = "staging"
  region  = "eu-west-1"
}
