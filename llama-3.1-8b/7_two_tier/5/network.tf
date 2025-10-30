resource "aws_vpc" "vpc_project" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-project"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "ig_project" {
  vpc_id = aws_vpc.vpc_project.id
  tags = {
    Name = "ig-project"
  }
}

# Create public subnets
resource "aws_subnet" "public_1" {
  cidr_block              = var.public_1_cidr
  vpc_id                  = aws_vpc.vpc_project.id
  availability_zone       = var.web1_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public_1"
  }
}

resource "aws_subnet" "public_2" {
  cidr_block              = var.public_2_cidr
  vpc_id                  = aws_vpc.vpc_project.id
  availability_zone       = var.web2_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public_2"
  }
}

# Create private subnets
resource "aws_subnet" "private_1" {
  cidr_block              = var.private_1_cidr
  vpc_id                  = aws_vpc.vpc_project.id
  availability_zone       = var.web1_az
  map_public_ip_on_launch = false
  tags = {
    Name = "private_1"
  }
}

resource "aws_subnet" "private_2" {
  cidr_block              = var.private_2_cidr
  vpc_id                  = aws_vpc.vpc_project.id
  availability_zone       = var.web2_az
  map_public_ip_on_launch = false
  tags = {
    Name = "private_2"
  }
}
