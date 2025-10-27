variable "aws-region" {
  description = "The AWS region to deploy the infrastructure in."
  type        = string
  default     = "us-east-1"
}

variable "vpc-cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "ami-id" {
  description = "The AMI ID for the EC2 instances."
  type        = string
  default     = "ami-052064a798f08f0d3" # Amazon Linux 2 in us-east-1
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
