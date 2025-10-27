resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

resource "aws_route_table_association" "public" {
  count = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_az1" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "private-route-table-az1"
  }
}

resource "aws_route" "private_nat_az1" {
  route_table_id         = aws_route_table.private_az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id        = aws_nat_gateway.main_nat[0].id
}

resource "aws_route_table_association" "private_az1" {
  subnet_id      = aws_subnet.private[0].id
  route_table_id = aws_route_table.private_az1.id
}

resource "aws_route_table" "private_az2" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "private-route-table-az2"
  }
}

resource "aws_route" "private_nat_az2" {
  route_table_id         = aws_route_table.private_az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id        = aws_nat_gateway.main_nat[1].id
}

resource "aws_route_table_association" "private_az2" {
  subnet_id      = aws_subnet.private[1].id
  route_table_id = aws_route_table.private_az2.id
}
