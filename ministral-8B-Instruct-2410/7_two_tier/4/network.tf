resource "aws_vpc" "project_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-project"
  }
}

resource "aws_internet_gateway" "project_ig" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "ig-project"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id     = aws_vpc.project_vpc.id
  cidr_block = var.public_subnet_cidr_1
  map_public_ip_on_launch = true
  availability_zone = var.web1_az

  tags = {
    Name = "public_1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id     = aws_vpc.project_vpc.id
  cidr_block = var.public_subnet_cidr_2
  map_public_ip_on_launch = true
  availability_zone = var.web2_az

  tags = {
    Name = "public_2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id     = aws_vpc.project_vpc.id
  cidr_block = var.private_subnet_cidr_1
  availability_zone = var.web1_az

  tags = {
    Name = "private_1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id     = aws_vpc.project_vpc.id
  cidr_block = var.private_subnet_cidr_2
  availability_zone = var.web2_az

  tags = {
    Name = "private_2"
  }
}

resource "aws_route_table" "project_rt" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_ig.id
  }

  tags = {
    Name = "project-rt"
  }
}

resource "aws_route_table_association" "public_1_association" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.project_rt.id
}

resource "aws_route_table_association" "public_2_association" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.project_rt.id
}
