data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC
resource "aws_vpc" "main-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "main-igw"
  }
}

# Create Public Subnets
resource "aws_subnet" "public-subnet-1" {
  cidr_block              = "10.0.0.0/24"
  vpc_id                  = aws_vpc.main-vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet AZ 1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.main-vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet AZ 2"
  }
}

# Create Private Subnets
resource "aws_subnet" "private-subnet-1" {
  cidr_block        = "10.0.10.0/24"
  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "Private Subnet AZ 1"
  }
}

resource "aws_subnet" "private-subnet-2" {
  cidr_block        = "10.0.11.0/24"
  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "Private Subnet AZ 2"
  }
}

# Allocate Elastic IPs for NAT Gateways
resource "aws_eip" "nat-eip-1" {
  vpc = true
  tags = {
    Name = "NAT EIP AZ 1"
  }
}

resource "aws_eip" "nat-eip-2" {
  vpc = true
  tags = {
    Name = "NAT EIP AZ 2"
  }
}

# Create NAT Gateways
resource "aws_nat_gateway" "nat-gw-1" {
  allocation_id = aws_eip.nat-eip-1.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
    Name = "NAT GW AZ 1"
  }
}

resource "aws_nat_gateway" "nat-gw-2" {
  allocation_id = aws_eip.nat-eip-2.id
  subnet_id     = aws_subnet.public-subnet-2.id
  tags = {
    Name = "NAT GW AZ 2"
  }
}

# Create Route Tables
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "Public RT"
  }
}

resource "aws_route_table" "private-rt-1" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "Private RT AZ 1"
  }
}

resource "aws_route_table" "private-rt-2" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "Private RT AZ 2"
  }
}

# Create Public Route
resource "aws_route" "public-rt-0-0-0-0" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-igw.id
}

# Create Private Routes
resource "aws_route" "private-rt-1-0-0-0" {
  route_table_id         = aws_route_table.private-rt-1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gw-1.id
}

resource "aws_route" "private-rt-2-0-0-0" {
  route_table_id         = aws_route_table.private-rt-2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gw-2.id
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "public-subnet-1-association" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-subnet-2-association" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-subnet-1-association" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-rt-1.id
}

resource "aws_route_table_association" "private-subnet-2-association" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-rt-2.id
}
