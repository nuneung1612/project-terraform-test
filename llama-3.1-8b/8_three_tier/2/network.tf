resource "aws_vpc" "three-tier-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "three-tier-vpc"
  }
}

# Subnets
resource "aws_subnet" "three-tier-web-subnet-1" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.three-tier-vpc.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "three-tier-web-subnet-1"
  }
}

resource "aws_subnet" "three-tier-web-subnet-2" {
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.three-tier-vpc.id
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "three-tier-web-subnet-2"
  }
}

resource "aws_subnet" "three-tier-app-subnet-1" {
  cidr_block              = "10.0.3.0/24"
  vpc_id                  = aws_vpc.three-tier-vpc.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-app-subnet-1"
  }
}

resource "aws_subnet" "three-tier-app-subnet-2" {
  cidr_block              = "10.0.4.0/24"
  vpc_id                  = aws_vpc.three-tier-vpc.id
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-app-subnet-2"
  }
}

resource "aws_subnet" "three-tier-db-subnet-1" {
  cidr_block              = "10.0.5.0/24"
  vpc_id                  = aws_vpc.three-tier-vpc.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-db-subnet-1"
  }
}

resource "aws_subnet" "three-tier-db-subnet-2" {
  cidr_block              = "10.0.6.0/24"
  vpc_id                  = aws_vpc.three-tier-vpc.id
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-db-subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "three-tier-igw" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-igw"
  }
}

# Public Route Table
resource "aws_route_table" "three-tier-public-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-public-rt"
  }
}

resource "aws_route" "three-tier-public-rt-igw" {
  route_table_id         = aws_route_table.three-tier-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.three-tier-igw.id
}

# Private Route Table
resource "aws_route_table" "three-tier-private-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-private-rt"
  }
}

resource "aws_route" "three-tier-private-rt-nat" {
  route_table_id         = aws_route_table.three-tier-private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id        = aws_nat_gateway.three-tier-nat-gw.id
}

# NAT Gateway
resource "aws_nat_gateway" "three-tier-nat-gw" {
  allocation_id = aws_eip.three-tier-eip.id
  subnet_id     = aws_subnet.three-tier-web-subnet-1.id
  tags = {
    Name = "three-tier-nat-gw"
  }
}

resource "aws_eip" "three-tier-eip" {
  vpc = true
  tags = {
    Name = "three-tier-eip"
  }
}
