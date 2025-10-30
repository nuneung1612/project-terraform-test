provider "aws" {
  region  = "us-east-1"
  version = "~> 5.0"
}

resource "aws_vpc" "vpc-project" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "vpc-project"
  }
}

resource "aws_internet_gateway" "ig-project" {
  vpc_id = aws_vpc.vpc-project.id
  tags = {
    Name = "ig-project"
  }
}

resource "aws_subnet" "public_1" {
  cidr_block              = var.public_1_cidr
  vpc_id                  = aws_vpc.vpc-project.id
  availability_zone       = var.web1_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public_1"
  }
}

resource "aws_subnet" "public_2" {
  cidr_block              = var.public_2_cidr
  vpc_id                  = aws_vpc.vpc-project.id
  availability_zone       = var.web2_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public_2"
  }
}

resource "aws_subnet" "private_1" {
  cidr_block        = var.private_1_cidr
  vpc_id            = aws_vpc.vpc-project.id
  availability_zone = var.web1_az
  tags = {
    Name = "private_1"
  }
}

resource "aws_subnet" "private_2" {
  cidr_block        = var.private_2_cidr
  vpc_id            = aws_vpc.vpc-project.id
  availability_zone = var.web2_az
  tags = {
    Name = "private_2"
  }
}
