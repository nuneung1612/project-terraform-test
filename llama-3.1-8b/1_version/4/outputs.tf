output "aws_region" {
  value       = var.aws_region
  description = "AWS region to deploy resources"
}

output "state_bucket_name" {
  value       = var.state_bucket_name
  description = "Name of the local state bucket"
}
