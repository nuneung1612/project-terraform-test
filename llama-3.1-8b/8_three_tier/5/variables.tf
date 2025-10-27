variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR"
}

variable "key_pair_name" {
  type        = string
  default     = "3-tier-key-pair"
  description = "Key pair name"
}

variable "ami_id" {
  type        = string
  default     = "ami-052064a798f08f0d3"
  description = "AMI ID"
}

variable "db_instance_type" {
  type        = string
  default     = "db.t3.micro"
  description = "DB instance type"
}

variable "db_storage" {
  type        = number
  default     = 10
  description = "DB storage"
}

variable "db_username" {
  type        = string
  sensitive   = true
  description = "DB username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "DB password"
}

variable "db_name" {
  type        = string
  default     = "mydb"
  description = "DB name"
}
