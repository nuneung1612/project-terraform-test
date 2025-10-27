// FILENAME: variables.tf

variable "aws_region" {
  description = "The AWS region where the infrastructure will be deployed."
  type        = string
  default     = "us-east-1"
}