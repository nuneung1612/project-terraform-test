variable "backend_bucket_name" {
  description = "S3 bucket name for backend storage"
  type        = string
  sensitive   = false
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
  sensitive   = false
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}
