# ===================================================================
# network.tf
# ===================================================================

locals {
  project_prefix = var.config["project-prefix"]

  # Subnet CIDRs
  web_cidrs = {
    a = "10.0.1.0/24" # public
    b = "10.0.2.0/24" # public
  }
  app_cidrs = {
    a = "10.0.3.0/24" # private
    b = "10.0.4.0/24" # private
  }
  db_cidrs = {
    a = "10.0.5.0/24" # private
    b = "10.0.6.0/24" # private
  }

  azs = {
    a = "us-east-1a"
    b = "us-east-1b"
  }

  name_tags = {
    vpc                    = "${local.project_prefix}-vpc"
    igw                    = "${local.project_prefix}-igw"
    eip_nat                = "${local.project_prefix}-eip-nat"
    nat_gw                 = "${local.project_prefix}-nat-gateway"
    route_public           = "${local.project_prefix}-rt-public"
    route_private_app      = "${local.project_prefix}-rt-private-app"
    subnet_web_a           = "${local.project_prefix}-subnet-web-a"
    subnet_web_b           = "${local.project_prefix}-subnet-web-b"
    subnet_app_a           = "${local.project_prefix}-subnet-app-a"
    subnet_app_b           = "${local.project_prefix}-subnet-app-b"
    subnet_db_a            = "${local.project_prefix}-subnet-db-a"
    subnet_db_b            = "${local.project_prefix}-subnet-db-b"
    sg_alb_web             = "${local.project_prefix}-sg-alb-web"
    sg_web_instances       = "${local.project_prefix}-sg-web-instances"
    sg_alb_app             = "${local.project_prefix}-sg-alb-app"
    sg_app_instances       = "${local.project_prefix}-sg-app-instances"
    sg_db                  = "${local.project_prefix}-sg-db"
  }
}

resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = local.name_tags.vpc
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.name_tags.igw
  }
}

# Public Web subnets (two AZs)
resource "aws_subnet" "web_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.web_cidrs.a
  availability_zone       = local.azs.a
  map_public_ip_on_launch = true

  tags = {
    Name = local.name_tags.subnet_web_a
    Tier = "web"
  }
}

resource "aws_subnet" "web_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.web_cidrs.b
  availability_zone       = local.azs.b
  map_public_ip_on_launch = true

  tags = {
    Name = local.name_tags.subnet_web_b
    Tier = "web"
  }
}

# Private App subnets (two AZs)
resource "aws_subnet" "app_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.app_cidrs.a
  availability_zone = local.azs.a

  tags = {
    Name = local.name_tags.subnet_app_a
    Tier = "app"
  }
}

resource "aws_subnet" "app_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.app_cidrs.b
  availability_zone = local.azs.b

  tags = {
    Name = local.name_tags.subnet_app_b
    Tier = "app"
  }
}

# Private DB subnets (two AZs)
resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.db_cidrs.a
  availability_zone = local.azs.a

  tags = {
    Name = local.name_tags.subnet_db_a
    Tier = "db"
  }
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.db_cidrs.b
  availability_zone = local.azs.b

  tags = {
    Name = local.name_tags.subnet_db_b
    Tier = "db"
  }
}

# Elastic IP for NAT
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = local.name_tags.eip_nat
  }
}

# NAT Gateway in a public subnet
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web_a.id

  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = local.name_tags.nat_gw
  }
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.name_tags.route_public
  }
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "web_a" {
  subnet_id      = aws_subnet.web_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "web_b" {
  subnet_id      = aws_subnet.web_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.name_tags.route_private_app
  }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private_app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "app_a" {
  subnet_id      = aws_subnet.app_a.id
  route_table_id = aws_route_table.private_app.id
}

resource "aws_route_table_association" "app_b" {
  subnet_id      = aws_subnet.app_b.id
  route_table_id = aws_route_table.private_app.id
}

# DB subnets typically use same private RT (no direct internet)
resource "aws_route_table_association" "db_a" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.private_app.id
}

resource "aws_route_table_association" "db_b" {
  subnet_id      = aws_subnet.db_b.id
  route_table_id = aws_route_table.private_app.id
}