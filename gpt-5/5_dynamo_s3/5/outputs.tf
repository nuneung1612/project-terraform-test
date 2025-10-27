output "backend_bucket_id" {
  description = "ID of the S3 backend bucket"
  value       = aws_s3_bucket.backend.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.tf_lock.name
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}
