variable "aws_region" {
  description = "The AWS region to deploy resources in."
  default     = "us-east-1"
}

variable "s3_backend_bucket_name" {
  description = "The name of the S3 bucket to use for the Terraform backend."
  default     = "josephy-1212312121"
}

variable "dynamodb_lock_table_name" {
  description = "The name of the DynamoDB table to use for state locking."
  default     = "mycomponents_tf_lockid_2"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}
