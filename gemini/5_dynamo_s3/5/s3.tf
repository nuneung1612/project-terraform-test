# This resource creates the S3 bucket that will be used to store the Terraform state file.

resource "aws_s3_bucket" "backend_bucket" {
  bucket = "josephy-1212312121"

  tags = {
    Name = "Backend_Bucket"
  }
}

# Enables versioning on the S3 bucket to keep a history of the state file.
resource "aws_s3_bucket_versioning" "backend_bucket_versioning" {
  bucket = aws_s3_bucket.backend_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Configures server-side encryption for the S3 bucket.
resource "aws_s3_bucket_server_side_encryption_configuration" "backend_bucket_sse" {
  bucket = aws_s3_bucket.backend_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
