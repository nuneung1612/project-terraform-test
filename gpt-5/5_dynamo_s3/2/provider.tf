########################################
# Provider
########################################
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}