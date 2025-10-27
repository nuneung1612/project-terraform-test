# =========================================================
# 0_backend_bootstrap/versions.tf
# Bootstrap stack: creates S3 bucket + DynamoDB table for state
# =========================================================
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
