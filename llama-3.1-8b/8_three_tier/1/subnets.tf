resource "aws_subnet" "three-tier-web-subnet-1a" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.three-tier-vpc.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "three-tier-web-subnet-1a"
  }
}

resource "aws_subnet" "three-tier-web-subnet-1b" {
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.three-tier-vpc.id
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "three-tier-web-subnet-1b"
  }
}

resource "aws_subnet" "three-tier-app-subnet-1a" {
  cidr_block              = "10.0.3.0/24"
  vpc_id                  = aws_vpc.three-tier-vpc.id
  availability_zone       = "us-east-1a"
  tags = {
    Name = "three-tier-app-subnet-1a"
  }
}

resource "aws_subnet" "three-tier-app-subnet-1b" {
  cidr_block              = "10.0.4.0/24"
  vpc_id                  = aws_vpc.three-tier-vpc.id
  availability_zone       = "us-east-1b"
  tags = {
    Name = "three-tier-app-subnet-1b"
  }
}

resource "aws_subnet" "three-tier-db-subnet-1a" {
  cidr_block              = "10.0.5.0/24"
  vpc_id                  = aws_vpc.three-tier-vpc.id
  availability_zone       = "us-east-1a"
  tags = {
    Name = "three-tier-db-subnet-1a"
  }
}

resource "aws_subnet" "three-tier-db-subnet-1b" {
  cidr_block              = "10.0.6.0/24"
  vpc_id                  = aws_vpc.three-tier-vpc.id
  availability_zone       = "us-east-1b"
  tags = {
    Name = "three-tier-db-subnet-1b"
  }
}
