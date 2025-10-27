# This block specifies the required version of Terraform.
# It ensures that the code is run with a compatible Terraform version.
terraform {
  required_version = ">= 1.0.0"

  # This block defines the required providers for this configuration.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # This block configures the backend for storing the Terraform state file.
  # "local" backend stores the state file on the local filesystem where Terraform is run.
  backend "local" {
    path = "terraform.tfstate"
  }
}

# This block configures the AWS provider.
# It sets the default region for all AWS resources created in this configuration.
provider "aws" {
  region = "us-east-1"
}

