# --- Data Sources ---

# Fetches the available availability zones in the configured AWS region.
# This allows for dynamic and resilient AZ selection.
data "aws_availability_zones" "available" {
  state = "available"
}

# --- VPC ---

# Creates the main Virtual Private Cloud (VPC).
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# --- Subnets ---

# Creates two public subnets, one in each of the first two available AZs.
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Creates two private subnets, aligned with the same AZs as the public subnets.
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# --- Internet Connectivity ---

# Creates an Internet Gateway to allow communication between the VPC and the internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Allocates two Elastic IPs for the NAT Gateways.
resource "aws_eip" "nat" {
  count = 2
  # depends_on is used to prevent potential race conditions where the EIP
  # might be allocated before the Internet Gateway is attached to the VPC.
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "nat-eip-${count.index + 1}"
  }
}

# Creates two NAT Gateways, one in each public subnet, for high availability.
# Private subnets will use these to access the internet.
resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}

# --- Routing ---

# Creates a single route table for all public subnets.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

# Adds a route to the public route table to direct internet-bound traffic
# to the Internet Gateway.
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associates both public subnets with the public route table.
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Creates a separate route table for each private subnet.
# This is necessary to route traffic to the NAT Gateway in the same AZ.
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table-az-${count.index + 1}"
  }
}

# Adds a route to each private route table to direct internet-bound traffic
# to its corresponding NAT Gateway in the same AZ.
resource "aws_route" "private_nat_access" {
  count                  = 2
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# Associates each private subnet with its dedicated private route table.
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
