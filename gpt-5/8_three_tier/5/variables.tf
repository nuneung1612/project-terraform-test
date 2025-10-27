// variables.tf
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "Name prefix for all resources (will be used as 'three-tier-...')"
  type        = string
  default     = "three-tier"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-052064a798f08f0d3"
}

variable "key_pair_name" {
  description = "Existing key pair name"
  type        = string
  default     = "3-tier-key-pair"
}

variable "user_data_file" {
  description = "Path to user-data.sh"
  type        = string
  default     = "user-data.sh"
}

variable "asg_sizes" {
  description = "ASG sizes (min, desired, max)"
  type = object({
    min     = number
    desired = number
    max     = number
  })
  default = {
    min     = 1
    desired = 2
    max     = 4
  }
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "mydb"
}
