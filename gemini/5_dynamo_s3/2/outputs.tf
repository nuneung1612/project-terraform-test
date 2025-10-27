# Defines outputs for the created resources.

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for the Terraform backend."
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table used for state locking."
  value       = aws_dynamodb_table.terraform_lock.name
}

output "vpc_id" {
  description = "The ID of the main VPC."
  value       = aws_vpc.main.id
}
