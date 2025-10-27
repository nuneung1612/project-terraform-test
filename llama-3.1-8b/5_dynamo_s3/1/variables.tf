variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
  sensitive   = true
  default     = "josephy-1212312121"
}

variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table name"
  sensitive   = true
  default     = "mycomponents_tf_lockid_2"
}

variable "lock_id_key" {
  type        = string
  description = "DynamoDB table hash key"
  default     = "LockID"
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "instance_tenancy" {
  type        = string
  description = "Default instance tenancy"
  default     = "default"
}

variable "vpc_name" {
  type        = string
  description = "VPC name"
  default     = "main"
}
