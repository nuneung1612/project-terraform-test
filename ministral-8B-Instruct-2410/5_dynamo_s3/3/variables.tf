variable "bucket_name" {
  description = "The name of the S3 bucket for backend storage"
  type        = string
  default     = "josephy-1212312121"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for state locking"
  type        = string
  default     = "mycomponents_tf_lockid_2"
}
