variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "key_pair_name" {
  description = "Name of the key pair"
  type        = string
  default     = "three-tier-key-pair"
}

variable "ami_id" {
  description = "AMI ID for the instances"
  type        = string
  default     = "ami-052064a798f08f0d3"
}
