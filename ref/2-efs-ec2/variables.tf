variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_ami" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0341d95f75f311023" 
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "efs-multi-az"
}

variable "efs_mount_point" {
  description = "Mount point for EFS"
  type        = string
  default     = "/mnt/efs"
}

variable "key_name" {
  description = "private key for ec2"
  type = string
  default = "ec2-key"
  
}