resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "three-tier-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.app[0].id, 0)
  tags = {
    Name = "three-tier-nat-gateway"
  }
}
