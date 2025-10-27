provider "aws" {
  region  = "us-west-2"
  version = "~> 5.0"
}

variable "bucket_name" {
  description = "The name of the S3 bucket used for storing Terraform state"
  default     = "josephy-1212312121"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table used for state locking"
  default     = "mycomponents_tf_lockid_2"
}

resource "aws_s3_bucket" "backend" {
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

resource "aws_dynamodb_table" "lock" {
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
