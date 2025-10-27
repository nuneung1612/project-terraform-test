# Specifies the minimum version of Terraform required to apply this configuration.
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    # Defines the required AWS provider from HashiCorp and sets its minimum version.
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # Configures the backend to store the Terraform state file locally.
  # This is suitable for single-developer environments.
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Configures the AWS provider with the desired region.
# All resources created by this configuration will be deployed to us-east-1.
provider "aws" {
  region = "us-east-1"
}
