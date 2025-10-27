# -----------------------------
# network.tf
# -----------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "three-tier-igw"
  }
}

resource "aws_subnet" "web_az1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.web_subnet_cidr_az1
  availability_zone       = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "three-tier-subnet-web-${var.az1}"
    Tier = "web"
  }
}

resource "aws_subnet" "web_az2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.web_subnet_cidr_az2
  availability_zone       = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "three-tier-subnet-web-${var.az2}"
    Tier = "web"
  }
}

resource "aws_subnet" "app_az1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_subnet_cidr_az1
  availability_zone = var.az1

  tags = {
    Name = "three-tier-subnet-app-${var.az1}"
    Tier = "app"
  }
}

resource "aws_subnet" "app_az2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_subnet_cidr_az2
  availability_zone = var.az2

  tags = {
    Name = "three-tier-subnet-app-${var.az2}"
    Tier = "app"
  }
}

resource "aws_subnet" "db_az1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_subnet_cidr_az1
  availability_zone = var.az1

  tags = {
    Name = "three-tier-subnet-db-${var.az1}"
    Tier = "db"
  }
}

resource "aws_subnet" "db_az2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_subnet_cidr_az2
  availability_zone = var.az2

  tags = {
    Name = "three-tier-subnet-db-${var.az2}"
    Tier = "db"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "three-tier-eip-nat"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web_az1.id

  # Explicit dependency as requested
  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "three-tier-natgw"
  }
}
# Public route table for web subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "three-tier-rt-public"
  }
}

resource "aws_route_table_association" "web_az1" {
  subnet_id      = aws_subnet.web_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "web_az2" {
  subnet_id      = aws_subnet.web_az2.id
  route_table_id = aws_route_table.public.id
}

# Private route table for app subnets (route to NAT)
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "three-tier-rt-private-app"
  }
}

resource "aws_route_table_association" "app_az1" {
  subnet_id      = aws_subnet.app_az1.id
  route_table_id = aws_route_table.private_app.id
}

resource "aws_route_table_association" "app_az2" {
  subnet_id      = aws_subnet.app_az2.id
  route_table_id = aws_route_table.private_app.id
}

# Private route table for DB subnets (no internet egress)
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "three-tier-rt-private-db"
  }
}

resource "aws_route_table_association" "db_az1" {
  subnet_id      = aws_subnet.db_az1.id
  route_table_id = aws_route_table.private_db.id
}

resource "aws_route_table_association" "db_az2" {
  subnet_id      = aws_subnet.db_az2.id
  route_table_id = aws_route_table.private_db.id
}
