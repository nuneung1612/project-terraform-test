resource "aws_route_table" "project-rt" {
  vpc_id = aws_vpc.vpc-project.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig-project.id
  }
  tags = {
    Name = "project-rt"
  }
}

resource "aws_route_table_association" "public_1-association" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.project-rt.id
}

resource "aws_route_table_association" "public_2-association" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.project-rt.id
}
