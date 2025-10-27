############################
# network.tf
############################
resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name_prefix}vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}igw"
  }
}

# Subnets
resource "aws_subnet" "web_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.subnets.web.a.cidr
  availability_zone       = local.subnets.web.a.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}subnet-web-a"
    Tier = "web"
  }
}

resource "aws_subnet" "web_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.subnets.web.b.cidr
  availability_zone       = local.subnets.web.b.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}subnet-web-b"
    Tier = "web"
  }
}

resource "aws_subnet" "app_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.subnets.app.a.cidr
  availability_zone       = local.subnets.app.a.az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}subnet-app-a"
    Tier = "app"
  }
}

resource "aws_subnet" "app_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.subnets.app.b.cidr
  availability_zone       = local.subnets.app.b.az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}subnet-app-b"
    Tier = "app"
  }
}

resource "aws_subnet" "db_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.subnets.db.a.cidr
  availability_zone       = local.subnets.db.a.az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}subnet-db-a"
    Tier = "db"
  }
}

resource "aws_subnet" "db_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.subnets.db.b.cidr
  availability_zone       = local.subnets.db.b.az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}subnet-db-b"
    Tier = "db"
  }
}

# EIP & NAT Gateway (in web_a)
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}eip-nat"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web_a.id

  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "${var.name_prefix}natgw"
  }
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name_prefix}rtb-public"
  }
}

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.name_prefix}rtb-private-app"
  }
}

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.this.id

  # No default route to the internet/NAT to keep DB isolated

  tags = {
    Name = "${var.name_prefix}rtb-private-db"
  }
}

# Associations
resource "aws_route_table_association" "web_a" {
  subnet_id      = aws_subnet.web_a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "web_b" {
  subnet_id      = aws_subnet.web_b.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "app_a" {
  subnet_id      = aws_subnet.app_a.id
  route_table_id = aws_route_table.private_app.id
}
resource "aws_route_table_association" "app_b" {
  subnet_id      = aws_subnet.app_b.id
  route_table_id = aws_route_table.private_app.id
}
resource "aws_route_table_association" "db_a" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.private_db.id
}
resource "aws_route_table_association" "db_b" {
  subnet_id      = aws_subnet.db_b.id
  route_table_id = aws_route_table.private_db.id
}
