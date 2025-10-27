provider "aws" {
  region  = var.aws_region
  version = " ~> 5.0"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_subnet" "web_us-east-1a" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "three-tier-web-us-east-1a"
  }
}

resource "aws_subnet" "web_us-east-1b" {
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "three-tier-web-us-east-1b"
  }
}

resource "aws_subnet" "app_us-east-1a" {
  cidr_block              = "10.0.3.0/24"
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-app-us-east-1a"
  }
}

resource "aws_subnet" "app_us-east-1b" {
  cidr_block              = "10.0.4.0/24"
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-app-us-east-1b"
  }
}

resource "aws_subnet" "db_us-east-1a" {
  cidr_block              = "10.0.5.0/24"
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-db-us-east-1a"
  }
}

resource "aws_subnet" "db_us-east-1b" {
  cidr_block              = "10.0.6.0/24"
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-db-us-east-1b"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "three-tier-igw"
  }
}

resource "aws_eip" "nat" {
  vpc      = true
  tags = {
    Name = "three-tier-eip-nat"
  }
}

resource "aws_nat_gateway" "main" {
  subnet_id = aws_subnet.web_us-east-1a.id
  tags = {
    Name = "three-tier-nat"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "three-tier-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "three-tier-private-rt"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "web_us-east-1a" {
  subnet_id      = aws_subnet.web_us-east-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "web_us-east-1b" {
  subnet_id      = aws_subnet.web_us-east-1b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "app_us-east-1a" {
  subnet_id      = aws_subnet.app_us-east-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "app_us-east-1b" {
  subnet_id      = aws_subnet.app_us-east-1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db_us-east-1a" {
  subnet_id      = aws_subnet.db_us-east-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db_us-east-1b" {
  subnet_id      = aws_subnet.db_us-east-1b.id
  route_table_id = aws_route_table.private.id
}
