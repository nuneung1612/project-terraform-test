# AWS Region
variable "region" {
  description = "AWS region for deployment (us-east-1)"
  type        = string
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for all resources (us-east-1a)"
  type        = string
}

# EC2 Configuration
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t2.micro" # Using t2.micro as safe default
}

variable "key_pair_name" {
  description = "The name of the existing AWS Key Pair for SSH access (vockey)"
  type        = string
}
