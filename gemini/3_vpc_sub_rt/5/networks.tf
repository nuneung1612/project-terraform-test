# -----------------------------------------------------------------------------
# DATA SOURCES
# -----------------------------------------------------------------------------

# Fetch available Availability Zones in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# -----------------------------------------------------------------------------
# SUBNETS
# -----------------------------------------------------------------------------

# Create two public subnets in different Availability Zones
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = format("10.0.%d.0/24", count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Create two private subnets in the same Availability Zones as the public ones
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = format("10.0.%d.0/24", count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# -----------------------------------------------------------------------------
# INTERNET CONNECTIVITY (IGW, NAT, EIP)
# -----------------------------------------------------------------------------

# Create a single Internet Gateway for the VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Create two Elastic IPs, one for each NAT Gateway
resource "aws_eip" "nat" {
  count = 2

  tags = {
    Name = "nat-eip-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Create two NAT Gateways, one in each public subnet
resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  # A NAT Gateway needs the Internet Gateway to be attached to the VPC
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "nat-gateway-${data.aws_availability_zones.available.names[count.index]}"
  }
}


# -----------------------------------------------------------------------------
# ROUTING
# -----------------------------------------------------------------------------

# Create a single route table for all public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

# Create a default route in the public route table to the Internet Gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate both public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create a dedicated route table for each private subnet
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Create a default route in each private route table to its corresponding NAT Gateway
resource "aws_route" "private_nat_access" {
  count                  = 2
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# Associate each private subnet with its dedicated private route table
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
