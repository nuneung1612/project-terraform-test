# Defines the AWS resources required for the Terraform backend:
# an S3 bucket for state storage and a DynamoDB table for state locking.

# S3 bucket to store the Terraform state file
resource "aws_s3_bucket" "tf_state" {
  bucket = var.backend_bucket_name

  tags = {
    Name = "Backend_Bucket"
  }
}

# Enable versioning on the S3 bucket to keep a history of the state files
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for state locking to prevent concurrent state modifications
resource "aws_dynamodb_table" "tf_lock" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}
