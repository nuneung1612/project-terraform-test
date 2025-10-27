// provider.tf
provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Project = var.project_name
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
