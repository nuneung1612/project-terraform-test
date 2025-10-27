// FILENAME: routing.tf

# --- Public Routing Configuration ---

# A single route table to be shared by all public subnets.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

# The default route that sends all non-local traffic (0.0.0.0/0) to the Internet Gateway.
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


# --- Private Routing Configuration ---

# Creates two separate route tables, one for each private subnet/AZ.
# This is key for AZ-independent routing to the respective NAT Gateways.
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# The default route for each private route table, sending internet-bound traffic
# to the NAT Gateway located in the same Availability Zone.
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