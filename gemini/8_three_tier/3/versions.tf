terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws-region
}

# Local backend for storing the Terraform state file
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
