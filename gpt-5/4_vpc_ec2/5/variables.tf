// variables.tf
variable "region" {
  description = "AWS region to deploy resources into."
  type        = string
}

variable "vpc_cidr" {
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
  description = "Availability Zone to place all subnets and instances (e.g., us-east-1a)."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "ssh_key_name" {
  description = "Existing EC2 Key Pair name to use for SSH access."
  type        = string
  sensitive   = true
}

variable "default_tags" {
  description = "Map of default tags to apply to all resources."
  type        = map(string)
  default     = {}
}
