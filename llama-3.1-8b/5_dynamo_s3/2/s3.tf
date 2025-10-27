# Define the S3 bucket
resource "aws_s3_bucket" "backend_bucket" {
  bucket = "josephy-1212312121"

  # Define bucket tags
  tags = {
    Name = "Backend_Bucket"
  }

  # Enable versioning
  versioning {
    enabled = true
  }

  # Configure server-side encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
