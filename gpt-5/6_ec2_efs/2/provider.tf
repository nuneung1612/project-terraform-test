# =========================================================
# provider.tf
# =========================================================
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Common tags
locals {
  common_tags = {
    Project = var.project_name
  }
}
