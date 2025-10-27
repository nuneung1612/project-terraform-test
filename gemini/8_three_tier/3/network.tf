# VPC
resource "aws_vpc" "three-tier-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "three-tier-vpc"
  }
}

# Subnets
# --- Web Tier (Public) ---
resource "aws_subnet" "web-subnet-a" {
  vpc_id                  = aws_vpc.three-tier-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws-region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "three-tier-web-subnet-a"
  }
}

resource "aws_subnet" "web-subnet-b" {
  vpc_id                  = aws_vpc.three-tier-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws-region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "three-tier-web-subnet-b"
  }
}

# --- App Tier (Private) ---
resource "aws_subnet" "app-subnet-a" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws-region}a"
  tags = {
    Name = "three-tier-app-subnet-a"
  }
}

resource "aws_subnet" "app-subnet-b" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws-region}b"
  tags = {
    Name = "three-tier-app-subnet-b"
  }
}

# --- DB Tier (Private) ---
resource "aws_subnet" "db-subnet-a" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "${var.aws-region}a"
  tags = {
    Name = "three-tier-db-subnet-a"
  }
}

resource "aws_subnet" "db-subnet-b" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "${var.aws-region}b"
  tags = {
    Name = "three-tier-db-subnet-b"
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
  tags = {
    Name = "three-tier-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "three-tier-nat-gw" {
  allocation_id = aws_eip.three-tier-nat-eip.id
  subnet_id     = aws_subnet.web-subnet-a.id
  tags = {
    Name = "three-tier-nat-gw"
  }
  depends_on = [aws_internet_gateway.three-tier-igw]
}

# Route Tables
# --- Public Route Table ---
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.three-tier-igw.id
  }
  tags = {
    Name = "three-tier-public-rt"
  }
}

# --- Private Route Table ---
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.three-tier-nat-gw.id
  }
  tags = {
    Name = "three-tier-private-rt"
  }
}

# Route Table Associations
# --- Public ---
resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.web-subnet-a.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.web-subnet-b.id
  route_table_id = aws_route_table.public-rt.id
}

# --- Private ---
resource "aws_route_table_association" "private-a" {
  subnet_id      = aws_subnet.app-subnet-a.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-b" {
  subnet_id      = aws_subnet.app-subnet-b.id
  route_table_id = aws_route_table.private-rt.id
}
