resource "aws_vpc" "example" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.tags, { Name = "Example VPC" })
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
  tags   = merge(var.tags, { Name = "Example Internet Gateway" })
}

resource "aws_subnet" "public" {
  cidr_block              = var.public_subnet_cidr
  vpc_id                  = aws_vpc.example.id
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "Example Public Subnet" })
}

resource "aws_subnet" "private" {
  cidr_block              = var.private_subnet_cidr
  vpc_id                  = aws_vpc.example.id
  availability_zone       = var.availability_zone
  tags                    = merge(var.tags, { Name = "Example Private Subnet" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id
  tags   = merge(var.tags, { Name = "Example Public Route Table" })
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.example.id
  tags   = merge(var.tags, { Name = "Example Private Route Table" })
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.example.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.example.id
  subnet_id     = aws_subnet.public.id
  tags          = merge(var.tags, { Name = "Example NAT Gateway" })
}

resource "aws_eip" "example" {
  vpc = true
  tags = merge(var.tags, { Name = "Example Elastic IP" })
}
