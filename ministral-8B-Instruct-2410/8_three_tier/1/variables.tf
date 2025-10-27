variable "region" {
  description = "The AWS region to deploy the infrastructure in"
  type        = string
  default     = "us-east-1"
}

variable "db_username" {
  description = "The database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The database password"
  type        = string
  sensitive   = true
}

variable "key_pair_name" {
  description = "The name of the key pair to use for instances"
  type        = string
  default     = "3-tier-key-pair"
}
