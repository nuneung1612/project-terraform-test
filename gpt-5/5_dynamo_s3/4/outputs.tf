########################################
# outputs.tf
########################################
output "backend_bucket_id" {
  description = "ID of the backend S3 bucket."
  value       = aws_s3_bucket.backend.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for state locking."
  value       = aws_dynamodb_table.tf_lock.name
}

output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.main.id
}
