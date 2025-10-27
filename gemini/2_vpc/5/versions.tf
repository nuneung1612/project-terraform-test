# Specifies the required version of Terraform.
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    # Defines the AWS provider and its version constraint.
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configures the AWS provider, setting the region to us-east-1.
provider "aws" {
  region = "us-east-1"
}
