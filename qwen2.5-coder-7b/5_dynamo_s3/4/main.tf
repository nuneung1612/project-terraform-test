provider "aws" {
  region = "us-west-2"
}

# Variables
variable "bucket_name" {
  description = "The name of the S3 bucket"
  default     = "josephy-1212312121"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  default     = "mycomponents_tf_lockid_2"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Backend Configuration
terraform {
  required_version = ">= 1.0.0"
  backend "s3" {
    bucket         = var.bucket_name
    key            = "terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = var.dynamodb_table_name
  }
}

# S3 Bucket
resource "aws_s3_bucket" "backend_bucket" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "Backend_Bucket"
  }
}

# DynamoDB Table
resource "aws_dynamodb_table" "tf_state_lock" {
  name         = var.dynamodb_table_name
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "State_Lock_Table"
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "main"
  }
}
