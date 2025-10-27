output "backend_bucket_name" {
  description = "The name of the S3 bucket used for backend storage"
  value       = aws_s3_bucket.backend_bucket.bucket
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.state_lock_table.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}
