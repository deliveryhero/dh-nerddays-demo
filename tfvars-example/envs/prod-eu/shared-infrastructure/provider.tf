terraform {
  required_version = "0.13.5"

  backend "s3" {
    encrypt = "true"
    bucket  = "terraform"
    key     = "prod-eu/shared-infrastructure.tfstate"
    region  = "eu-west-1"
    profile = "production"
  }
}

provider "aws" {
  profile = "production"
  region  = "eu-west-1"
}
