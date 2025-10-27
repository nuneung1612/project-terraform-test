# Data source to dynamically get Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# 1. Create a VPC named main-vpc
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# 2. Create an Internet Gateway named main-igw and attach it to the VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# 3. and 4. Create Public and Private Subnets (two of each, one per AZ)
# Use a local variable for easier management of subnet configuration
locals {
  public_subnets = [
    { cidr = "10.0.0.0/24", name = "Public Subnet AZ 1", az_index = 0 },
    { cidr = "10.0.1.0/24", name = "Public Subnet AZ 2", az_index = 1 },
  ]
  private_subnets = [
    { cidr = "10.0.10.0/24", name = "Private Subnet AZ 1", az_index = 0 },
    { cidr = "10.0.11.0/24", name = "Private Subnet AZ 2", az_index = 1 },
  ]
}

resource "aws_subnet" "public" {
  for_each                = { for s in local.public_subnets : s.name => s }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = data.aws_availability_zones.available.names[each.value.az_index]
  map_public_ip_on_launch = true # Requirement 3

  tags = {
    Name = each.value.name
  }
}

resource "aws_subnet" "private" {
  for_each          = { for s in local.private_subnets : s.name => s }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = data.aws_availability_zones.available.names[each.value.az_index]

  tags = {
    Name = each.value.name
  }
}

# 5. Allocate 2 Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"

  tags = {
    Name = "NAT EIP ${count.index + 1}"
  }
}

# 6. Create 2 NAT Gateways (one per AZ)
# The index (0 or 1) corresponds to the subnet index and EIP index
resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  # Place the NAT Gateway in the corresponding Public Subnet
  subnet_id = aws_subnet.public[local.public_subnets[count.index].name].id

  tags = {
    Name = "NAT Gateway AZ ${count.index + 1}"
  }
  # A dependency on the internet gateway is implicitly created by the route table association later.
  # Explicitly adding it here is good practice to ensure EIP allocation happens after subnet creation.
  depends_on = [aws_subnet.public, aws_eip.nat]
}

# 7. Create Route Tables

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Public Route Table"
  }
}

# Public Route: route 0.0.0.0/0 to Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Private Route Tables (one per AZ)
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Private Route Table AZ ${count.index + 1}"
  }
}

# Private Routes: route 0.0.0.0/0 to the corresponding NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count                  = 2
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  # Use the corresponding NAT Gateway based on the count index (0 or 1)
  nat_gateway_id = aws_nat_gateway.main[count.index].id
}

# 8. Associate Route Tables

# Public Route Table -> both Public Subnets
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Each Private Route Table -> its respective Private Subnet
resource "aws_route_table_association" "private" {
  count = 2
  # Private Route Table index 0 associates with Private Subnet index 0 (AZ 1)
  # Private Route Table index 1 associates with Private Subnet index 1 (AZ 2)
  subnet_id      = aws_subnet.private[local.private_subnets[count.index].name].id
  route_table_id = aws_route_table.private[count.index].id
}
