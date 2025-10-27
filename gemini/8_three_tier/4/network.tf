resource "aws_vpc" "three_tier" {
  cidr_block = var.vpc-cidr

  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_subnet" "web" {
  count             = length(var.web-subnet-cidrs)
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = var.web-subnet-cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "three-tier-web-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "app" {
  count             = length(var.app-subnet-cidrs)
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = var.app-subnet-cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three-tier-app-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "db" {
  count             = length(var.db-subnet-cidrs)
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = var.db-subnet-cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three-tier-db-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "three_tier" {
  vpc_id = aws_vpc.three_tier.id

  tags = {
    Name = "three-tier-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "three-tier-nat-eip"
  }
}

resource "aws_nat_gateway" "three_tier" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web[0].id

  tags = {
    Name = "three-tier-nat-gw"
  }

  depends_on = [aws_internet_gateway.three_tier]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.three_tier.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.three_tier.id
  }

  tags = {
    Name = "three-tier-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.web)
  subnet_id      = aws_subnet.web[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.three_tier.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.three_tier.id
  }

  tags = {
    Name = "three-tier-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.app)
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.private.id
}

data "aws_availability_zones" "available" {
  state = "available"
}
