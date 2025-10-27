// variables.tf
variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "nuneung-efs-web"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs (must match azs length)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
  description = "Availability Zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use for EC2"
  type        = string
  default     = "ami-0341d95f75f311023" # Amazon Linux 2023 in us-east-1
}

variable "instance_count" {
  description = "Number of EC2 instances to launch (and EIPs to attach)"
  type        = number
  default     = 2
}

variable "efs_mount_point" {
  description = "Where to mount EFS on the instances"
  type        = string
  default     = "/mnt/efs"
}

