
provider "aws" {
  region  = var.aws_region
  version = "~> 5.0"
}

resource "aws_vpc" "three-tier-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_internet_gateway" "three-tier-igw" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-igw"
  }
}

resource "aws_subnet" "three-tier-web-subnet-1" {
  cidr_block        = var.web_subnet_cidrs[0]
  vpc_id            = aws_vpc.three-tier-vpc.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "three-tier-web-subnet-1"
  }
}

resource "aws_subnet" "three-tier-web-subnet-2" {
  cidr_block        = var.web_subnet_cidrs[1]
  vpc_id            = aws_vpc.three-tier-vpc.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "three-tier-web-subnet-2"
  }
}

resource "aws_subnet" "three-tier-app-subnet-1" {
  cidr_block        = var.app_subnet_cidrs[0]
  vpc_id            = aws_vpc.three-tier-vpc.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "three-tier-app-subnet-1"
  }
}

resource "aws_subnet" "three-tier-app-subnet-2" {
  cidr_block        = var.app_subnet_cidrs[1]
  vpc_id            = aws_vpc.three-tier-vpc.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "three-tier-app-subnet-2"
  }
}

resource "aws_subnet" "three-tier-db-subnet-1" {
  cidr_block        = var.db_subnet_cidrs[0]
  vpc_id            = aws_vpc.three-tier-vpc.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "three-tier-db-subnet-1"
  }
}

resource "aws_subnet" "three-tier-db-subnet-2" {
  cidr_block        = var.db_subnet_cidrs[1]
  vpc_id            = aws_vpc.three-tier-vpc.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "three-tier-db-subnet-2"
  }
}

resource "aws_eip" "three-tier-eip" {
  vpc = true
  tags = {
    Name = "three-tier-eip"
  }
}

resource "aws_nat_gateway" "three-tier-nat-gw" {
  allocation_id = aws_eip.three-tier-eip.id
  subnet_id     = aws_subnet.three-tier-web-subnet-1.id
  tags = {
    Name = "three-tier-nat-gw"
  }
}

resource "aws_route_table" "three-tier-web-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-web-rt"
  }
}

resource "aws_route" "three-tier-web-igw" {
  route_table_id         = aws_route_table.three-tier-web-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.three-tier-igw.id
}

resource "aws_route_table" "three-tier-app-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-app-rt"
  }
}

resource "aws_route" "three-tier-app-nat-gw" {
  route_table_id         = aws_route_table.three-tier-app-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.three-tier-nat-gw.id
}

resource "aws_route_table_association" "three-tier-web-subnet-1-rt-assoc" {
  subnet_id      = aws_subnet.three-tier-web-subnet-1.id
  route_table_id = aws_route_table.three-tier-web-rt.id
}

resource "aws_route_table_association" "three-tier-web-subnet-2-rt-assoc" {
  subnet_id      = aws_subnet.three-tier-web-subnet-2.id
  route_table_id = aws_route_table.three-tier-web-rt.id
}

resource "aws_route_table_association" "three-tier-app-subnet-1-rt-assoc" {
  subnet_id      = aws_subnet.three-tier-app-subnet-1.id
  route_table_id = aws_route_table.three-tier-app-rt.id
}

resource "aws_route_table_association" "three-tier-app-subnet-2-rt-assoc" {
  subnet_id      = aws_subnet.three-tier-app-subnet-2.id
  route_table_id = aws_route_table.three-tier-app-rt.id
}

resource "aws_route_table_association" "three-tier-db-subnet-1-rt-assoc" {
  subnet_id      = aws_subnet.three-tier-db-subnet-1.id
  route_table_id = aws_route_table.three-tier-app-rt.id
}

resource "aws_route_table_association" "three-tier-db-subnet-2-rt-assoc" {
  subnet_id      = aws_subnet.three-tier-db-subnet-2.id
  route_table_id = aws_route_table.three-tier-app-rt.id
}
