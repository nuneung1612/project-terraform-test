# VPC
resource "aws_vpc" "three-tier-vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "three-tier-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "three-tier-igw" {
  vpc_id = aws_vpc.three-tier-vpc.id

  tags = {
    Name = "three-tier-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "three-tier-nat-eip" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.three-tier-igw]

  tags = {
    Name = "three-tier-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "three-tier-nat-gw" {
  allocation_id = aws_eip.three-tier-nat-eip.id
  subnet_id     = aws_subnet.three-tier-web-subnet[0].id

  depends_on = [aws_internet_gateway.three-tier-igw]

  tags = {
    Name = "three-tier-nat-gw"
  }
}

# Web Tier Subnets (Public)
resource "aws_subnet" "three-tier-web-subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.three-tier-vpc.id
  cidr_block              = var.web-subnet-cidrs[count.index]
  availability_zone       = var.availability-zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "three-tier-web-subnet-${count.index + 1}"
  }
}

# App Tier Subnets (Private)
resource "aws_subnet" "three-tier-app-subnet" {
  count             = 2
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = var.app-subnet-cidrs[count.index]
  availability_zone = var.availability-zones[count.index]

  tags = {
    Name = "three-tier-app-subnet-${count.index + 1}"
  }
}

# Database Tier Subnets (Private)
resource "aws_subnet" "three-tier-db-subnet" {
  count             = 2
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = var.db-subnet-cidrs[count.index]
  availability_zone = var.availability-zones[count.index]

  tags = {
    Name = "three-tier-db-subnet-${count.index + 1}"
  }
}

# Public Route Table
resource "aws_route_table" "three-tier-public-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.three-tier-igw.id
  }

  tags = {
    Name = "three-tier-public-rt"
  }
}

# Private Route Table
resource "aws_route_table" "three-tier-private-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.three-tier-nat-gw.id
  }

  tags = {
    Name = "three-tier-private-rt"
  }
}

# Route Table Associations - Web Subnets
resource "aws_route_table_association" "three-tier-web-rta" {
  count          = 2
  subnet_id      = aws_subnet.three-tier-web-subnet[count.index].id
  route_table_id = aws_route_table.three-tier-public-rt.id
}

# Route Table Associations - App Subnets
resource "aws_route_table_association" "three-tier-app-rta" {
  count          = 2
  subnet_id      = aws_subnet.three-tier-app-subnet[count.index].id
  route_table_id = aws_route_table.three-tier-private-rt.id
}

# Route Table Associations - DB Subnets
resource "aws_route_table_association" "three-tier-db-rta" {
  count          = 2
  subnet_id      = aws_subnet.three-tier-db-subnet[count.index].id
  route_table_id = aws_route_table.three-tier-private-rt.id
}