variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "vpc-cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public-subnet-cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "public-subnet-az" {
  description = "Availability zone for public subnet"
  type        = string
}

variable "private-subnet-cidr" {
  description = "CIDR block for private subnet"
  type        = string
}

variable "private-subnet-az" {
  description = "Availability zone for private subnet"
  type        = string
}

variable "ami" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance-type" {
  description = "Instance type for EC2 instances"
  type        = string
}

variable "key-name" {
  description = "SSH key pair name"
  type        = string
}