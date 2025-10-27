resource "aws_eip" "nat_eip" {
  count = 2

  vpc = true
}

resource "aws_nat_gateway" "main_nat" {
  count         = 2
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "nat-gateway-${count.index}"
  }
}
