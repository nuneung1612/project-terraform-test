# Specifies the required versions for Terraform and the AWS provider.
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configures the AWS provider with the specified region.
provider "aws" {
  region = var.aws_region
}
