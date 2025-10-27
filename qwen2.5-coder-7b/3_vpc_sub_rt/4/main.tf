provider "aws" {
  required_version = ">= 1.0.0"
  region           = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags             = { Name = "main-vpc" }
}

data "aws_availability_zones" "available" {}

locals {
  az_count = length(data.aws_availability_zones.available.names)
}

resource "aws_subnet" "public_subnets" {
  count            = local.az_count * 2
  vpc_id           = aws_vpc.main_vpc.id
  cidr_block       = var.public_subnet_cidr_blocks[count.index % length(var.public_subnet_cidr_blocks)]
  map_public_ip_on_launch = true
  availability_zone = element(data.aws_availability_zones.available.names, count.index % local.az_count)
  tags             = { Name = "${element(["public-subnet"], count.index % 2)}-${count.index}" }
}

resource "aws_subnet" "private_subnets" {
  count            = local.az_count * 2
  vpc_id           = aws_vpc.main_vpc.id
  cidr_block       = var.private_subnet_cidr_blocks[count.index % length(var.private_subnet_cidr_blocks)]
  availability_zone = element(data.aws_availability_zones.available.names, count.index % local.az_count)
  tags             = { Name = "${element(["private-subnet"], count.index % 2)}-${count.index}" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = { Name = "main-igw" }
}

resource "aws_eip" "nat_gw_eips" {
  count = local.az_count
}

resource "aws_nat_gateway" "nat_gateways" {
  count         = local.az_count
  allocation_id = aws_eip.nat_gw_eips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  tags          = { Name = "nat-gateway-${count.index}" }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-route-table" }
}

resource "aws_route_table_association" "public_route_table_assocs" {
  count          = local.az_count * 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_tables" {
  count = local.az_count
  route {
    cidr_block              = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }
  tags = { Name = "private-route-table-${count.index}" }
}

resource "aws_route_table_association" "private_route_table_assocs" {
  count          = local.az_count * 2
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index div 2].id
}
