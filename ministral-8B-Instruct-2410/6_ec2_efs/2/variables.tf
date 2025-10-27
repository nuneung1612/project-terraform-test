variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr1" {
  description = "Subnet CIDR block for AZ 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_cidr2" {
  description = "Subnet CIDR block for AZ 2"
  type        = string
  default     = "10.0.2.0/24"
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

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0341d95f75f311023"
}

variable "efs_mount_point" {
  description = "EFS mount point"
  type        = string
  default     = "/mnt/efs"
}
