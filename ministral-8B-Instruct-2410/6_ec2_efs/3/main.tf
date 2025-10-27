provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "Subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-0341d95f75f311023"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "efs_mount_point" {
  description = "EFS mount point"
  type        = string
  default     = "/mnt/efs"
}

# Outputs
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "efs_id" {
  value = aws_efs_file_system.efs.id
}

output "dns_name" {
  value = aws_vpc.vpc.dns_support
}

output "instance_ids" {
  value = aws_instance.instance[*].id
}

output "public_ips" {
  value = aws_instance.instance[*].public_ip
}

output "private_ips" {
  value = aws_instance.instance[*].private_ip
}

output "availability_zones_used" {
  value = var.availability_zones
}

# Networking
module "networking" {
  source             = "./network"
  vpc_cidr           = var.vpc_cidr
  subnet_cidrs       = var.subnet_cidrs
  availability_zones = var.availability_zones
  project_name       = var.project_name
}

# EC2 Instances
module "ec2" {
  source             = "./ec2"
  instance_type      = var.instance_type
  ami_id             = var.ami_id
  project_name       = var.project_name
  availability_zones = var.availability_zones
  efs_mount_point    = var.efs_mount_point
  efs_id             = module.network.efs_id
  efs_mount_target   = module.network.efs_mount_target
}

# EFS
module "efs" {
  source          = "./efs"
  efs_mount_point = var.efs_mount_point
  project_name    = var.project_name
}

# Security Groups
resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2-sg-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "efs_sg" {
  name_prefix = "efs-sg-"

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
