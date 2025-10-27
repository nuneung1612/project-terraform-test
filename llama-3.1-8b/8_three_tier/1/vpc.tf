resource "aws_vpc" "three-tier-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_internet_gateway" "three-tier-igw" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-igw"
  }
}

resource "aws_nat_gateway" "three-tier-nat-gw" {
  allocation_id = aws_eip.three-tier-eip.id
  subnet_id     = aws_subnet.three-tier-web-subnet-1a.id
  tags = {
    Name = "three-tier-nat-gw"
  }
}

resource "aws_eip" "three-tier-eip" {
  vpc = true
  tags = {
    Name = "three-tier-eip"
  }
}
