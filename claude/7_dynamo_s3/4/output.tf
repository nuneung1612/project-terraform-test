# outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "backend_bucket_arn" {
  description = "ARN of the backend S3 bucket"
  value       = aws_s3_bucket.backend.arn
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB state lock table"
  value       = aws_dynamodb_table.state_lock.arn
}