# This file defines the resources for the S3 backend bucket.

# S3 bucket for storing Terraform state. The bucket name must be globally unique.
resource "aws_s3_bucket" "terraform_state" {
  bucket = "josephy-1212312121"

  tags = {
    Name = "Backend_Bucket"
  }
}

# Enable versioning on the S3 bucket to keep a history of state files.
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure server-side encryption for the S3 bucket to protect state file data at rest.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the S3 bucket as a security best practice.
resource "aws_s3_bucket_public_access_block" "terraform_state_pab" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
