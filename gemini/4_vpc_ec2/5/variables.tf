# Contains all the variable declarations for the Terraform configuration.

variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet."
  type        = string
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet."
  type        = string
}

variable "availability_zone" {
  description = "The availability zone for the subnets."
  type        = string
}

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instances."
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instances."
  type        = string
}

variable "key_name" {
  description = "The name of the EC2 key pair to use for SSH access."
  type        = string
}
