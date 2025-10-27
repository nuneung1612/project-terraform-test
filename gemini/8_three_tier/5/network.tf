# VPC Creation
resource "aws_vpc" "main" {
  cidr_block           = var.vpc-cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-vpc"
    }
  )
}

# --- Subnets ---
# Web Tier Public Subnets
resource "aws_subnet" "web" {
  count                   = length(var.web-subnet-cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.web-subnet-cidrs, count.index)
  availability_zone       = element(var.availability-zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-web-subnet-${count.index + 1}"
      Tier = "Web"
    }
  )
}

# App Tier Private Subnets
resource "aws_subnet" "app" {
  count             = length(var.app-subnet-cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.app-subnet-cidrs, count.index)
  availability_zone = element(var.availability-zones, count.index)

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-app-subnet-${count.index + 1}"
      Tier = "App"
    }
  )
}

# DB Tier Private Subnets
resource "aws_subnet" "db" {
  count             = length(var.db-subnet-cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.db-subnet-cidrs, count.index)
  availability_zone = element(var.availability-zones, count.index)

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-db-subnet-${count.index + 1}"
      Tier = "DB"
    }
  )
}

# --- Gateways ---
# Internet Gateway for public subnets
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-igw"
    }
  )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-nat-eip"
    }
  )
}

# NAT Gateway for private subnets
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web[0].id

  # Explicit dependency on the Internet Gateway
  depends_on = [aws_internet_gateway.main]

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-nat-gw"
    }
  )
}

# --- Route Tables ---
# Public Route Table for Web Tier
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-public-rt"
    }
  )
}

# Private Route Table for App & DB Tiers
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-private-rt"
    }
  )
}

# --- Route Table Associations ---
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.web)
  subnet_id      = element(aws_subnet.web[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  count          = length(aws_subnet.app)
  subnet_id      = element(aws_subnet.app[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

# --- DB Subnet Group ---
resource "aws_db_subnet_group" "default" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = aws_subnet.db[*].id

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-db-subnet-group"
    }
  )
}
