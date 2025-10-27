# subnets.tf

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = format("10.0.%d.0/24", count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = format("public-subnet-%s", data.aws_availability_zones.available.names[count.index])
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = format("10.0.%d.0/24", count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = format("private-subnet-%s", data.aws_availability_zones.available.names[count.index])
  }
}