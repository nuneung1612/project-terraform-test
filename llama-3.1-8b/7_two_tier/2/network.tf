# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  alias  = "east"

  version = "~> 5.0"
}

# VPC
resource "aws_vpc" "vpc_project" {
  cidr_block           = var.vpc_cidr != "" ? var.vpc_cidr : "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-project"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ig_project" {
  vpc_id = aws_vpc.vpc_project.id
  tags = {
    Name = "ig-project"
  }
}

# Public Subnets
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.vpc_project.id
  cidr_block              = var.public_1_cidr != "" ? var.public_1_cidr : "10.0.1.0/24"
  availability_zone       = var.public_1_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public_1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.vpc_project.id
  cidr_block              = var.public_2_cidr != "" ? var.public_2_cidr : "10.0.2.0/24"
  availability_zone       = var.public_2_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public_2"
  }
}

# Private Subnets
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.vpc_project.id
  cidr_block        = var.private_1_cidr != "" ? var.private_1_cidr : "10.0.3.0/24"
  availability_zone = var.private_1_az
  tags = {
    Name = "private_1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.vpc_project.id
  cidr_block        = var.private_2_cidr != "" ? var.private_2_cidr : "10.0.4.0/24"
  availability_zone = var.private_2_az
  tags = {
    Name = "private_2"
  }
}
