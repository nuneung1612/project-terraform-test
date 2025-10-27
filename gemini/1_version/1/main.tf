# ==============================================================================
# TERRAFORM SETTINGS
#
# Specifies the required Terraform version and backend configuration.
# The local backend stores the state file on the local filesystem.
# ==============================================================================
terraform {
  required_version = ">= 1.0.0"

  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# ==============================================================================
# PROVIDER CONFIGURATION
#
# Configures the AWS provider with the specified region.
# ==============================================================================
provider "aws" {
  region = var.aws_region
}
