# VPC
resource "aws_vpc" "tf-vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tf-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.tf-vpc.id
  cidr_block              = var.public-subnet-cidr
  availability_zone       = var.public-subnet-az
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.tf-vpc.id
  cidr_block        = var.private-subnet-cidr
  availability_zone = var.private-subnet-az

  tags = {
    Name = "private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "main-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat-eip" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }

  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateway
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "main-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Public Route Table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Private Route Table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public-rta" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

# Private Route Table Association
resource "aws_route_table_association" "private-rta" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}

# Public Security Group
resource "aws_security_group" "public-sg" {
  name        = "public-sg"
  description = "Security group for public instances"
  vpc_id      = aws_vpc.tf-vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-sg"
  }
}

# Private Security Group
resource "aws_security_group" "private-sg" {
  name        = "private-sg"
  description = "Security group for private instances"
  vpc_id      = aws_vpc.tf-vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc-cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}

# Public EC2 Instance
resource "aws_instance" "public-server" {
  ami                    = var.ami
  instance_type          = var.instance-type
  key_name               = var.key-name
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.public-sg.id]

  tags = {
    Name = "public-server"
  }
}

# Private EC2 Instance
resource "aws_instance" "private-server" {
  ami                    = var.ami
  instance_type          = var.instance-type
  key_name               = var.key-name
  subnet_id              = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.private-sg.id]

  tags = {
    Name = "private-server"
  }
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.tf-vpc.id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public-subnet.id
}

output "private_subnet_id" {
  description = "Private Subnet ID"
  value       = aws_subnet.private-subnet.id
}

output "public_instance_id" {
  description = "Public Server Instance ID"
  value       = aws_instance.public-server.id
}

output "public_instance_public_ip" {
  description = "Public Server Public IP"
  value       = aws_instance.public-server.public_ip
}

output "private_instance_id" {
  description = "Private Server Instance ID"
  value       = aws_instance.private-server.id
}

output "private_instance_private_ip" {
  description = "Private Server Private IP"
  value       = aws_instance.private-server.private_ip
}