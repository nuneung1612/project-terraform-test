resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "three-tier-public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "three-tier-private-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.web)
  subnet_id      = element(aws_subnet.web[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.app)
  subnet_id      = element(aws_subnet.app[*].id, count.index)
  route_table_id = aws_route_table.private.id
}
