provider "aws" {
  version = "~> 5.0"
  region  = var.region
}

variable "region" {
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "List of CIDR blocks for subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "Type of EC2 instances"
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  default     = "ami-0341d95f75f311023"
}

variable "project_name" {
  description = "Name of the project"
  default     = "my-project"
}

variable "efs_mount_point" {
  description = "Mount point for EFS"
  default     = "/mnt/efs"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project_name}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-igw" }
}

resource "aws_subnet" "public" {
  count                   = length(var.subnet_cidrs)
  cidr_block              = element(var.subnet_cidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project_name}-subnet-${count.index}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.project_name}-rt-public" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-sg-ec2"
  description = "Allow SSH and HTTP"
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
}

resource "aws_security_group" "efs" {
  name        = "${var.project_name}-sg-efs"
  description = "Allow NFS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port                 = 2049
    to_port                   = 2049
    protocol                  = "tcp"
    source_security_group_ids = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
  security_groups = [aws_security_group.efs.id]

  tags = { Name = "${var.project_name}-efs-mt-${count.index}" }
}

resource "aws_eip" "elastic_ip" {
  count = 2

  tags = { Name = "${var.project_name}-eip-${count.index}" }
}

resource "aws_instance" "example" {
  count                       = 2
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = "your-key-pair-name"
  subnet_id                   = element(aws_subnet.public[*].id, count.index)
  associate_public_ip_address = true
  user_data                   = filebase64("path/to/user-data.sh")
  user_data_replace_on_change = true
  vpc_security_group_ids      = [aws_security_group.ec2.id]

  tags = {
    Name    = "${var.project_name}-ec2-instance-${count.index}"
    Project = var.project_name
  }

  depends_on = [
    aws_efs_mount_target.mt[count.index],
  ]
}
