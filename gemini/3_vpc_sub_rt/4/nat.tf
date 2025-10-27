# nat.tf

resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"

  tags = {
    Name = format("nat-eip-%s", data.aws_availability_zones.available.names[count.index])
  }
}

resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = format("nat-gateway-%s", data.aws_availability_zones.available.names[count.index])
  }

  depends_on = [aws_internet_gateway.main]
}