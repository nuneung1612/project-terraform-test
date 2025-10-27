# Provisions the S3 bucket that will be used for storing the Terraform state file.
resource "aws_s3_bucket" "terraform_state" {
  bucket = "josephy-1212312121"

  tags = {
    Name = "Backend_Bucket"
  }
}

# Enables versioning on the S3 bucket to keep a history of state files.
# This is a critical best practice to prevent state loss or corruption.
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configures server-side encryption for the S3 bucket to protect the state file at rest.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Provisions the DynamoDB table used for Terraform state locking.
# This prevents concurrent operations on the state file, which can lead to corruption.
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "mycomponents_tf_lockid_2"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}
