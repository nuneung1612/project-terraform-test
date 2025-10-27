provider "aws" {
  region  = "us-west-2"
  version = "~> 5.0"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state storage"
  default     = "josephy-1212312121"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  default     = "mycomponents_tf_lockid_2"
}

resource "aws_s3_bucket" "backend" {
  bucket = var.s3_bucket_name
  acl    = "private"

  tags = {
    Name = "Backend_Bucket"
  }

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
}

resource "aws_dynamodb_table" "state_lock" {
  name          = var.dynamodb_table_name
  billing_mode  = "PAY_PER_REQUEST"
  hash_key      = "LockID"
  hash_key_type = "STRING"

  attribute {
    name = "LockID"
    type = "S"
  }
}
