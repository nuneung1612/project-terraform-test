terraform {
  # Require Terraform version 1.0.0 or higher
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Require AWS provider version ~> 5.0
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  
  # Apply safe defaults for tagging all resources for better management
  default_tags {
    tags = {
      Environment = "Dev"
      Project     = "Terraform-Project-Infra"
      ManagedBy   = "Terraform"
    }
  }
}
