// variables.tf
variable "region" {
  description = "AWS region to deploy into."
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
  description = "Availability Zone for both subnets and instances."
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "ssh_key_name" {
  description = "Existing SSH key pair name to associate with instances."
  type        = string
  sensitive   = true
}
