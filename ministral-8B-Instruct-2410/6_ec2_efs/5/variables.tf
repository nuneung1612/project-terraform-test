variable "aws_region" {
  description = "The AWS region to deploy the infrastructure."
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "The CIDR blocks for the subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "The availability zones to deploy the subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "The type of EC2 instance."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances."
  type        = string
  default     = "ami-0341d95f75f311023"
}

variable "user_data" {
  description = "The user data script for the EC2 instances."
  type        = string
}

variable "efs_mount_point" {
  description = "The mount point for the EFS."
  type        = string
  default     = "/mnt/efs"
}
