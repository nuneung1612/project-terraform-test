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

variable "availability_zone" {
  type        = string
  description = "Availability zone"
}

variable "ami_id" {
  type        = string
  description = "AMI ID"
  sensitive   = true
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key name"
  sensitive   = true
}

variable "public_ssh_from" {
  type        = string
  description = "Public security group SSH access from"
  default     = "0.0.0.0/0"
}

variable "private_ssh_from" {
  type        = string
  description = "Private security group SSH access from"
  default     = "10.0.0.0/16"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {
    Name        = "Example Infrastructure"
    Environment = "dev"
    Owner       = "Your Name"
  }
}
