provider "aws" {
  region                      = var.aws_region
  version                     = "~> 5.0"
  skip_credentials_validation = true
}

resource "aws_vpc" "vpc_project" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-project"
  }
}

resource "aws_internet_gateway" "ig_project" {
  vpc_id = aws_vpc.vpc_project.id

  tags = {
    Name = "ig-project"
  }
}

resource "aws_subnet" "public_1" {
  cidr_block              = var.public_subnet_cidr_1
  vpc_id                  = aws_vpc.vpc_project.id
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_1"
  }
}

resource "aws_subnet" "public_2" {
  cidr_block              = var.public_subnet_cidr_2
  vpc_id                  = aws_vpc.vpc_project.id
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_2"
  }
}

resource "aws_subnet" "private_1" {
  cidr_block              = var.private_subnet_cidr_1
  vpc_id                  = aws_vpc.vpc_project.id
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "private_1"
  }
}

resource "aws_subnet" "private_2" {
  cidr_block              = var.private_subnet_cidr_2
  vpc_id                  = aws_vpc.vpc_project.id
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "private_2"
  }
}
