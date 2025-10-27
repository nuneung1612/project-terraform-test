provider "aws" {
  region = "us-west-2"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for state storage"
  type        = string
  default     = "josephy-1212312121"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for state locking"
  type        = string
  default     = "mycomponents_tf_lockid_2"
}

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

resource "aws_dynamodb_table" "state_locking_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "State_Locking_Table"
  }
}
