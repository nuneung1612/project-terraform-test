// FILENAME: network.tf

# The Internet Gateway (IGW) is the entry/exit point for traffic between the VPC and the internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Allocates two Elastic IPs (EIPs), one for each NAT Gateway, to provide them with a
# static public IP address.
resource "aws_eip" "nat" {
  count = 2
  vpc   = true

  # This dependency ensures the Internet Gateway is created before the EIPs,
  # as the NAT Gateway that uses the EIP requires internet access for its creation.
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "nat-eip-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Creates two NAT Gateways, one in each public subnet, for high availability.
# Private subnets will use these to access the internet without being publicly exposed.
resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "main-nat-gw-${data.aws_availability_zones.available.names[count.index]}"
  }
}