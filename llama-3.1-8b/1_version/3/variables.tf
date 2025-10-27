variable "aws_region" {
  type        = string
  description = "AWS region"
  value       = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile name"
  sensitive   = true
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
  sensitive   = true
}
