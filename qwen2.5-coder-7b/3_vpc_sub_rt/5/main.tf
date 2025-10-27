provider "aws" {
  required_version = ">= 1.0.0"
  version          = "~> 5.0"
  region           = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for the public subnets"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for the private subnets"
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags                 = { Name = "main-vpc" }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags                    = { Name = "${aws_vpc.main.tags.Name}-public-${count.index}" }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidr_blocks, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags              = { Name = "${aws_vpc.main.tags.Name}-private-${count.index}" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${aws_vpc.main.tags.Name}-igw" }
}

resource "aws_eip" "nat_eips" {
  count = length(aws_subnet.public[*].id)
  tags  = { Name = "${aws_vpc.main.tags.Name}-nat-eip-${count.index}" }
}

resource "aws_nat_gateway" "nats" {
  count         = length(aws_subnet.public[*].id)
  allocation_id = element(aws_eip.nat_eips[*].id, count.index)
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  tags          = { Name = "${aws_vpc.main.tags.Name}-nat-gateway-${count.index}" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${aws_vpc.main.tags.Name}-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  count = length(aws_subnet.private[*].id)
  tags  = { Name = "${aws_vpc.main.tags.Name}-private-rt-${count.index}" }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private[*].id)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private_rt[*].id, count.index)
}
