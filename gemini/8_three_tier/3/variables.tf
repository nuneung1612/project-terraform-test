variable "aws-region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "ami-id" {
  description = "The AMI ID for the EC2 instances."
  type        = string
  default     = "ami-052064a798f08f0d3" # Amazon Linux 2 in us-east-1
}

variable "key-name" {
  description = "The name of the key pair to use for the EC2 instances."
  type        = string
  default     = "3-tier-key-pair"
}

variable "db-username" {
  description = "The username for the RDS database."
  type        = string
  sensitive   = true
}

variable "db-password" {
  description = "The password for the RDS database."
  type        = string
  sensitive   = true
}
