terraform {
  required_version = ">= 0.13.0"

  required_providers {
    mysql = {
      source  = "terraform-providers/mysql"
      version = "1.9.0"
    }
  }
}
