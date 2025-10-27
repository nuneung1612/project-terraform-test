# main.tf

# Specifies the minimum version of Terraform required to apply the configuration.
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # Configure the local backend for storing the Terraform state file.
  # The state file will be stored in a file named 'terraform.tfstate'
  # in the same directory where Terraform is run.
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Configure the AWS provider with the specified region.
# This block sets the default region for all AWS resources
# defined in this configuration.
provider "aws" {
  region = "us-east-1"
}