# =========================================================
# 1_infra/versions.tf
# Main stack: uses the S3 backend created by bootstrap.
# =========================================================
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "josephy-1212312121"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "mycomponents_tf_lockid_2"
  }
}
