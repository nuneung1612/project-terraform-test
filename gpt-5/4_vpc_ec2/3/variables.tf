# variables.tf
variable "region" {
  description = "AWS region for all resources."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone to place both subnets in (e.g., us-east-1a)."
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances."
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2 instances."
  type        = string
}

variable "ssh_key_name" {
  description = "Name of an existing EC2 Key Pair to associate with instances."
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
