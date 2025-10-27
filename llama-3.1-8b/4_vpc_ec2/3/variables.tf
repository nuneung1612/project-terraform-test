variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Public subnet CIDR block"
}

variable "private_subnet_cidr" {
  type        = string
  description = "Private subnet CIDR block"
}

variable "public_subnet_az" {
  type        = string
  description = "Public subnet availability zone"
}

variable "private_subnet_az" {
  type        = string
  description = "Private subnet availability zone"
}

variable "ami_id" {
  type        = string
  description = "AMI ID"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key name"
  sensitive   = true
}
