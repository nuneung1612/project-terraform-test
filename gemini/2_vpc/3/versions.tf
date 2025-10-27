# This file specifies the required Terraform version and the AWS provider configuration.

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS provider to use the us-east-1 region.
provider "aws" {
  region = "us-east-1"
}
