# Specifies the required Terraform version.
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configures the AWS provider, setting the default region.
provider "aws" {
  region = var.aws_region
}
