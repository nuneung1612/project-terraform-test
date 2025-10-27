provider "aws" {
  region  = var.aws_region
  version = "~> 5.0"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  name       = "three-tier-vpc"

  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  name   = "three-tier-igw"

  tags = {
    Name = "three-tier-igw"
  }
}

resource "aws_subnet" "web-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  name              = "three-tier-web-a"

  tags = {
    Name = "three-tier-web-a"
  }
}

resource "aws_subnet" "web-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  name              = "three-tier-web-b"

  tags = {
    Name = "three-tier-web-b"
  }
}

resource "aws_subnet" "app-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  name              = "three-tier-app-a"

  tags = {
    Name = "three-tier-app-a"
  }
}

resource "aws_subnet" "app-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  name              = "three-tier-app-b"

  tags = {
    Name = "three-tier-app-b"
  }
}

resource "aws_subnet" "db-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"
  name              = "three-tier-db-a"

  tags = {
    Name = "three-tier-db-a"
  }
}

resource "aws_subnet" "db-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"
  name              = "three-tier-db-b"

  tags = {
    Name = "three-tier-db-b"
  }
}

resource "aws_eip" "nat-eip" {
  vpc  = true
  name = "three-tier-nat-eip"

  tags = {
    Name = "three-tier-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.web-a.id
  name          = "three-tier-nat-gateway"

  tags = {
    Name = "three-tier-nat-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  name   = "three-tier-public-rtb"

  tags = {
    Name = "three-tier-public-rtb"
  }
}

resource "aws_route" "public-igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.web-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.web-b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  name   = "three-tier-private-rtb"

  tags = {
    Name = "three-tier-private-rtb"
  }
}

resource "aws_route" "private-nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private-a" {
  subnet_id      = aws_subnet.app-a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-b" {
  subnet_id      = aws_subnet.app-b.id
  route_table_id = aws_route_table.private.id

  depends_on = [aws_route_table_association.private-a]
}

resource "aws_route_table_association" "private-db-a" {
  subnet_id      = aws_subnet.db-a.id
  route_table_id = aws_route_table.private.id

  depends_on = [aws_route_table_association.private-b]
}

resource "aws_route_table_association" "private-db-b" {
  subnet_id      = aws_subnet.db-b.id
  route_table_id = aws_route_table.private.id

  depends_on = [aws_route_table_association.private-db-a]
}
