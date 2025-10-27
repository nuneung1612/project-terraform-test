resource "aws_s3_bucket" "backend_s3" {
  bucket = "josephy-1212312121"
  tags = {
    Name = "Backend_Bucket"
  }
}

# Enabling the bucket versioning
resource "aws_s3_bucket_versioning" "versioning1" {
  bucket = aws_s3_bucket.backend_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend_encryption" {
  bucket = aws_s3_bucket.backend_s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
