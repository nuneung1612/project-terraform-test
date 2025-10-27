variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "Name of the local state bucket"
  default     = "terraform-state-bucket"
}
