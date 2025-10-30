# Create route table
resource "aws_route_table" "project_rt" {
  vpc_id = aws_vpc.vpc_project.id
  tags = {
    Name = "project-rt"
  }
}

# Create route
resource "aws_route" "project_rt_route" {
  route_table_id         = aws_route_table.project_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig_project.id
}

# Associate public subnets with route table
resource "aws_route_table_association" "public_1_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.project_rt.id
}

resource "aws_route_table_association" "public_2_assoc" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.project_rt.id
}
