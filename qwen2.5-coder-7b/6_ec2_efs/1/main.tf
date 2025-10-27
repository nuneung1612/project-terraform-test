provider "aws" {
  region  = var.region
  version = "~> 5.0"
}

variable "region" {
  description = "The AWS region to deploy the infrastructure"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "The instance type to launch"
  default     = "t3.micro"
}

variable "ami_id" {
  description = "The AMI ID to use"
  default     = "ami-0341d95f75f311023"
}

variable "project_name" {
  description = "The name of the project"
  default     = "my-project"
}

variable "efs_mount_point" {
  description = "The mount point for the EFS"
  default     = "/mnt/efs"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project_name}-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-igw" }
}

resource "aws_subnet" "public" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)
  tags                    = { Name = "${var.project_name}-public-subnet-${count.index + 1}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.project_name}-public-rtb" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "elastic_ips" {
  count = length(aws_instance.ec2[*])
  vpc   = true
  tags  = { Name = "${var.project_name}-eip-${count.index + 1}" }
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow SSH and HTTP from anywhere"
  vpc_id      = aws_vpc.main.id

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

  tags = { Name = "${var.project_name}-ec2-sg" }
}

resource "aws_security_group" "efs" {
  name        = "${var.project_name}-efs-sg"
  description = "Allow NFS from EC2 security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port                = 2049
    to_port                  = 2049
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.ec2.id
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-efs-sg" }
}

resource "aws_efs_file_system" "main" {
  creation_token = var.project_name
  encrypted      = true
  kms_key_id     = "alias/aws/ebs"

  lifecycle_policy {
    transition_to_infrequent_access_after_days = 30
  }

  tags = { Name = "${var.project_name}-efs" }
}

resource "aws_efs_mount_target" "mt" {
  count           = length(aws_subnet.public)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = element(aws_subnet.public[*].id, count.index)
  security_groups = [aws_security_group.ec2.id]
}

resource "aws_instance" "ec2" {
  count                       = 2
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = "your-key-pair-name"
  subnet_id                   = element(aws_subnet.public[*].id, count.index)
  associate_public_ip_address = true
  user_data_replace_on_change = true
  security_groups             = [aws_security_group.ec2.id]

  root_block_device {
    volume_size = 20
  }

  depends_on = [
    aws_efs_mount_target.mt,
  ]

  tags = {
    Name    = "${var.project_name}-ec2-${count.index + 1}"
    Project = var.project_name
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "efs_id" {
  value = aws_efs_file_system.main.id
}

output "dns_name" {
  value = aws_vpc.main.dns_name
}

output "instance_ids" {
  value = aws_instance.ec2[*].id
}

output "public_ips" {
  value = aws_instance.ec2[*].public_ip
}

output "private_ips" {
  value = aws_instance.ec2[*].private_ip
}

output "availability_zones" {
  value = aws_subnet.public[*].availability_zone
}
