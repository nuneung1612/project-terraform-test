########################################
# Terraform & Backend Configuration
########################################
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # NOTE (bootstrap): This backend expects the S3 bucket and DynamoDB table
  # to already exist. If you're setting them up with this same config for the
  # first time, you can:
  # 1) Temporarily comment out the backend block below and run: terraform init && terraform apply
  # 2) Restore the backend block and run: terraform init -migrate-state
  # backend "s3" {
  #   bucket         = "josephy-1212312121"
  #   key            = "terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "mycomponents_tf_lockid_2"
  #   encrypt        = true
  # }
}
