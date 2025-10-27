resource "aws_route_table" "three-tier-web-route-table" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-web-route-table"
  }
}

resource "aws_route_table" "three-tier-app-route-table" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-app-route-table"
  }
}

resource "aws_route_table" "three-tier-db-route-table" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-db-route-table"
  }
}

resource "aws_route" "three-tier-web-route" {
  route_table_id         = aws_route_table.three-tier-web-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.three-tier-igw.id
}

resource "aws_route" "three-tier-app-route" {
  route_table_id         = aws_route_table.three-tier-app-route-table.id
  destination_cidr_block = aws_eip.three-tier-eip.public_ip
  gateway_id             = aws_nat_gateway.three-tier-nat-gw.id
  depends_on             = [aws_eip.three-tier-eip]
}

resource "aws_route" "three-tier-db-route" {
  route_table_id         = aws_route_table.three-tier-db-route-table.id
  destination_cidr_block = aws_eip.three-tier-eip.public_ip
  gateway_id             = aws_nat_gateway.three-tier-nat-gw.id
  depends_on             = [aws_eip.three-tier-eip]
}

resource "aws_route_table_association" "three-tier-web-subnet-1a" {
  subnet_id      = aws_subnet.three-tier-web-subnet-1a.id
  route_table_id = aws_route_table.three-tier-web-route-table.id
}

resource "aws_route_table_association" "three-tier-web-subnet-1b" {
  subnet_id      = aws_subnet.three-tier-web-subnet-1b.id
  route_table_id = aws_route_table.three-tier-web-route-table.id
}

resource "aws_route_table_association" "three-tier-app-subnet-1a" {
  subnet_id      = aws_subnet.three-tier-app-subnet-1a.id
  route_table_id = aws_route_table.three-tier-app-route-table.id
}

resource "aws_route_table_association" "three-tier-app-subnet-1b" {
  subnet_id      = aws_subnet.three-tier-app-subnet-1b.id
  route_table_id = aws_route_table.three-tier-app-route-table.id
}

resource "aws_route_table_association" "three-tier-db-subnet-1a" {
  subnet_id      = aws_subnet.three-tier-db-subnet-1a.id
  route_table_id = aws_route_table.three-tier-db-route-table.id
}

resource "aws_route_table_association" "three-tier-db-subnet-1b" {
  subnet_id      = aws_subnet.three-tier-db-subnet-1b.id
  route_table_id = aws_route_table.three-tier-db-route-table.id
}
