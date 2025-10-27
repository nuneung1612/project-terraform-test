# Configure the AWS provider
provider "aws" {
  region = var.aws_region
  version = "~> 5.0"
}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Internet Gateway Route
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

# Public Subnets
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet-${count.index+1}"
  }
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public" {
  count = 2
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# EFS Configuration
resource "aws_efs_file_system" "main" {
  creation_token = var.project_name
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encryption = "AES256"
  lifecycle_policy {
    transition_to_ia = 30
  }
  tags = {
    Name = "${var.project_name}-efs"
  }
}

# EFS Mount Targets
resource "aws_efs_mount_target" "main" {
  count = 2
  file_system_id = aws_efs_file_system.main.id
  subnet_id = aws_subnet.public[count.index].id
  security_groups = [aws_security_group.efs.id]
}

# EC2 Security Group
resource "aws_security_group" "ec2" {
  name = "${var.project_name}-ec2-sg"
  description = "Allow inbound traffic on port 22 and 80"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# EFS Security Group
resource "aws_security_group" "efs" {
  name = "${var.project_name}-efs-sg"
  description = "Allow inbound traffic on port 2049"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    source_security_group_id = aws_security_group.ec2.id
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-efs-sg"
  }
}

# EC2 Instances
resource "aws_instance" "main" {
  count = var.instance_count
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id = aws_subnet.public[count % 2].id
  key_name = var.key_name
  user_data = file("${path.module}/user-data.sh")
  depends_on = [aws_efs_mount_target.main]
  tags = {
    Name = "${var.project_name}-ec2-${count.index+1}"
  }
}

# Elastic IPs
resource "aws_eip" "main" {
  count = var.instance_count
  instance = aws_instance.main[count.index].id
  vpc = true
}

# Outputs
output "vpc_id" {
  value = aws_vpc.main.id
}

output "efs_id" {
  value = aws_efs_file_system.main.id
}

output "dns_name" {
  value = aws_efs_file_system.main.dns_name
}

output "instance_ids" {
  value = aws_instance.main.*.id
}

output "public_ips" {
  value = aws_eip.main.*.public_ip
}

output "private_ips" {
  value = aws_instance.main.*.private_ip
}

output "availability_zones" {
  value = aws_instance.main.*.availability_zone
}
