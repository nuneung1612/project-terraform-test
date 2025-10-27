# variables.tf
variable "project_name" {
  description = "A short, descriptive project name used for naming and tagging."
  type        = string
  default     = "prod-app"
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

