resource "aws_subnet" "web" {
  count             = length(local.subnets_web)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(local.subnets_web, count.index)
  availability_zone = element(local.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = format("three-tier-web-subnet-%d", count.index + 1)
  }
}

resource "aws_subnet" "app" {
  count             = length(local.subnets_app)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(local.subnets_app, count.index)
  availability_zone = element(local.azs, count.index)
  tags = {
    Name = format("three-tier-app-subnet-%d", count.index + 1)
  }
}

resource "aws_subnet" "db" {
  count             = length(local.subnets_db)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(local.subnets_db, count.index)
  availability_zone = element(local.azs, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = format("three-tier-db-subnet-%d", count.index + 1)
  }
}
