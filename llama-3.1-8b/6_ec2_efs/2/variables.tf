# Configure the AWS Provider
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS region to deploy the infrastructure in"
  sensitive   = true
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR block for the VPC"
}

variable "subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "The CIDR blocks for the subnets"
}

variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "The availability zones for the subnets"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "The instance type for the EC2 instances"
}

variable "ami_id" {
  type        = string
  default     = "ami-0341d95f75f311023"
  description = "The ID of the Amazon Linux 2023 AMI"
}

variable "project_name" {
  type        = string
  default     = "my-project"
  description = "The name of the project"
}

variable "efs_mount_point" {
  type        = string
  default     = "/mnt/efs"
  description = "The mount point for the EFS file system"
}

variable "num_instances" {
  type        = number
  default     = 2
  description = "The number of EC2 instances to deploy"
}
