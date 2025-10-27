// FILENAME: subnets.tf

# Creates two public subnets, one in each of the first two available AZs.
# These subnets will have direct access to the internet.
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  # Dynamically calculates CIDR blocks: 10.0.0.0/24, 10.0.1.0/24
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Creates two private subnets, one in each of the same two available AZs.
# These subnets are intended for backend resources and will not be directly
# accessible from the internet.
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  # Dynamically calculates CIDR blocks with an offset: 10.0.10.0/24, 10.0.11.0/24
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${data.aws_availability_zones.available.names[count.index]}"
  }
}