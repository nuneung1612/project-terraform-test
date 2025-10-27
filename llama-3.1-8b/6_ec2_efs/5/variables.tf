variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
  sensitive   = true
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR"
}

variable "subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "Subnet CIDRs"
}

variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "Availability zones"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Instance type"
}

variable "ami_id" {
  type        = string
  default     = "ami-0341d95f75f311023"
  description = "AMI ID"
}

variable "project_name" {
  type        = string
  default     = "my-project"
  description = "Project name"
}

variable "efs_mount_point" {
  type        = string
  default     = "/mnt/efs"
  description = "EFS mount point"
  sensitive   = true
}
