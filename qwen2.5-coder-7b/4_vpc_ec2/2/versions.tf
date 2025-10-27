terraform {
  required_version = ">= 1.0.0"
}

provider "aws" {
  region  = var.region
  version = "~> 5.0"
}
