variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "key_pair_name" {
  type        = string
  default     = "3-tier-key-pair"
  description = "Name of the existing key pair"
}

variable "ami_id" {
  type        = string
  default     = "ami-052064a798f08f0d3"
  description = "AMI ID for instances"
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

variable "db_storage" {
  type        = number
  default     = 10
  description = "DB storage in GB"
}

variable "db_instance_type" {
  type        = string
  default     = "db.t3.micro"
  description = "DB instance type"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type for ASG"
}

variable "min_asg_instances" {
  type        = number
  default     = 1
  description = "Minimum number of instances in ASG"
}

variable "desired_asg_instances" {
  type        = number
  default     = 2
  description = "Desired number of instances in ASG"
}

variable "max_asg_instances" {
  type        = number
  default     = 4
  description = "Maximum number of instances in ASG"
}
