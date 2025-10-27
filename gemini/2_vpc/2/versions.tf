# Specifies the minimum version of Terraform required to apply the configuration.
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    # Defines the required AWS provider and its version constraint.
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configures the AWS provider, setting the region for resource deployment.
provider "aws" {
  region = "us-east-1"
}
