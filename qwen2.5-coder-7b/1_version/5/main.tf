terraform {
  required_version = ">= 1.0.0"

  backend "local" {}
}

provider "aws" {
  version = ">= 5.0"
  region  = "us-east-1"
}
