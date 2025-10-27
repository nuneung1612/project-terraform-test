provider "aws" {
  region = var.aws_region
}

# VPC and Networking
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# EFS
resource "aws_efs_file_system" "efs" {
  creation_token = "${var.project_name}-efs"
  encrypted      = true
}

resource "aws_efs_mount_target" "efs" {
  count           = length(var.availability_zones)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.public[count.index].id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_lifecycle_policy" "lifecycle" {
  file_system_id = aws_efs_file_system.efs.id
  policy = jsonencode({
    Rules = [
      {
        ID = "transition-to-IA"
        Action = {
          Type = "TransitionToIA"
        }
        Transitions = [
          {
            Days = 30
          }
        ]
      }
    ]
  })
}

# EC2 Instances
resource "aws_instance" "ec2" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index].id
  key_name               = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = file("user-data.sh")

  tags = {
    Name = "${var.project_name}-instance-${count.index}"
  }

  depends_on = [
    aws_efs_mount_target.efs,
  ]

  provisioner "local-exec" {
    command = "echo ${aws_efs_mount_target.efs.0.id} > ${var.project_name}-efs-id.txt"
  }
}

resource "aws_eip" "eip" {
  count = 2
  vpc   = true
}

resource "aws_eip_association" "eip_assoc" {
  count         = 2
  instance_id   = aws_instance.ec2[count.index].id
  allocation_id = aws_eip.eip[count.index].id
}

# Security Groups
resource "aws_security_group" "ec2" {
  name   = "${var.project_name}-ec2-sg"
  vpc_id = aws_vpc.main.id

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
  name   = "${var.project_name}-efs-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Outputs
output "vpc_id" {
  value = aws_vpc.main.id
}

output "efs_id" {
  value = aws_efs_file_system.efs.id
}

output "dns_name" {
  value = aws_vpc.main.dns_support
}

output "instance_ids" {
  value = aws_instance.ec2[*].id
}

output "public_ips" {
  value = aws_eip_association.eip_assoc[*].public_ip
}

output "private_ips" {
  value = aws_instance.ec2[*].private_ip
}

output "availability_zones" {
  value = var.availability_zones
}
