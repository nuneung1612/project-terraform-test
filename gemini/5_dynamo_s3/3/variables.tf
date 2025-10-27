# Contains all the variable definitions for the Terraform configuration.

variable "aws_region" {
  description = "The AWS region where resources will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "backend_bucket_name" {
  description = "The name of the S3 bucket for storing Terraform state."
  type        = string
  default     = "josephy-1212312121"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking."
  type        = string
  default     = "mycomponents_tf_lockid_2"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the main VPC."
  type        = string
  default     = "10.0.0.0/16"
}
