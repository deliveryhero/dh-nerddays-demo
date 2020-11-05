terraform {
  required_version = "0.13.5"

  backend "s3" {
    encrypt = "true"
    bucket  = "terraform"
    key     = "prod-asia/shared-infrastructure.tfstate"
    region  = "ap-northeast-1"
    profile = "production"
  }
}

provider "aws" {
  profile = "production"
  region  = "ap-northeast-1"
}
