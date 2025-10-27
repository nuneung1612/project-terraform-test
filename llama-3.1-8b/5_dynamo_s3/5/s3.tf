terraform {
  required_version = ">= 1.0.0"
}

provider "aws" {
  region  = "us-east-1"
  version = "~> 5.0"
}

resource "aws_s3_bucket" "backend_bucket" {
  bucket = "josephy-1212312121"
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
