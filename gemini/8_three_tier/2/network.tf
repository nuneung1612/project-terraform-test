# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc-cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "three-tier-vpc"
  }
}

# Web Tier Subnets (Public)
resource "aws_subnet" "web" {
  count                   = length(var.web-subnet-cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.web-subnet-cidrs[count.index]
  availability_zone       = var.availability-zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "three-tier-web-subnet-${count.index + 1}"
  }
}

# App Tier Subnets (Private)
resource "aws_subnet" "app" {
  count             = length(var.app-subnet-cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.app-subnet-cidrs[count.index]
  availability_zone = var.availability-zones[count.index]

  tags = {
    Name = "three-tier-app-subnet-${count.index + 1}"
  }
}

# DB Tier Subnets (Private)
resource "aws_subnet" "db" {
  count             = length(var.db-subnet-cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db-subnet-cidrs[count.index]
  availability_zone = var.availability-zones[count.index]

  tags = {
    Name = "three-tier-db-subnet-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "three-tier-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "three-tier-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web[0].id

  tags = {
    Name = "three-tier-nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "three-tier-public-rt"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "three-tier-private-rt"
  }
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.web)
  subnet_id      = aws_subnet.web[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table Associations
resource "aws_route_table_association" "private_app" {
  count          = length(aws_subnet.app)
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.private.id
}
