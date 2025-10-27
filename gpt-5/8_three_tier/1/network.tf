# network.tf
locals {
  web_az_map = { for idx, cidr in var.web_subnet_cidrs : idx => {
    cidr = cidr
    az   = var.availability_zones[idx]
  } }
  app_az_map = { for idx, cidr in var.app_subnet_cidrs : idx => {
    cidr = cidr
    az   = var.availability_zones[idx]
  } }
  db_az_map = { for idx, cidr in var.db_subnet_cidrs : idx => {
    cidr = cidr
    az   = var.availability_zones[idx]
  } }
}

resource "aws_vpc" "three_tier" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_internet_gateway" "three_tier" {
  vpc_id = aws_vpc.three_tier.id

  tags = {
    Name = "three-tier-igw"
  }
}

# Public Web Subnets
resource "aws_subnet" "three_tier_web" {
  for_each = local.web_az_map

  vpc_id                  = aws_vpc.three_tier.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "three-tier-subnet-web-${each.key}"
    Tier = "web"
  }
}

# Private App Subnets
resource "aws_subnet" "three_tier_app" {
  for_each = local.app_az_map

  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "three-tier-subnet-app-${each.key}"
    Tier = "app"
  }
}

# Private DB Subnets
resource "aws_subnet" "three_tier_db" {
  for_each = local.db_az_map

  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "three-tier-subnet-db-${each.key}"
    Tier = "db"
  }
}

# Public Route Table -> IGW
resource "aws_route_table" "three_tier_public" {
  vpc_id = aws_vpc.three_tier.id

  tags = {
    Name = "three-tier-rt-public"
  }
}

resource "aws_route" "three_tier_public_default" {
  route_table_id         = aws_route_table.three_tier_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.three_tier.id
}

resource "aws_route_table_association" "three_tier_web_assoc" {
  for_each       = aws_subnet.three_tier_web
  subnet_id      = each.value.id
  route_table_id = aws_route_table.three_tier_public.id
}

# NAT Gateway (single, cost-aware) in first web subnet
resource "aws_eip" "three_tier_nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.three_tier]

  tags = {
    Name = "three-tier-nat-eip"
  }
}

resource "aws_nat_gateway" "three_tier" {
  allocation_id = aws_eip.three_tier_nat.id
  subnet_id     = values(aws_subnet.three_tier_web)[0].id

  tags = {
    Name = "three-tier-nat"
  }

  depends_on = [aws_internet_gateway.three_tier]
}

# Private Route Table for App Subnets -> NAT
resource "aws_route_table" "three_tier_private_app" {
  vpc_id = aws_vpc.three_tier.id

  tags = {
    Name = "three-tier-rt-private-app"
  }
}

resource "aws_route" "three_tier_private_app_default" {
  route_table_id         = aws_route_table.three_tier_private_app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.three_tier.id
}

resource "aws_route_table_association" "three_tier_app_assoc" {
  for_each       = aws_subnet.three_tier_app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.three_tier_private_app.id
}

# Private Route Table for DB Subnets (no internet route)
resource "aws_route_table" "three_tier_private_db" {
  vpc_id = aws_vpc.three_tier.id

  tags = {
    Name = "three-tier-rt-private-db"
  }
}

resource "aws_route_table_association" "three_tier_db_assoc" {
  for_each       = aws_subnet.three_tier_db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.three_tier_private_db.id
}

output "vpc_id" {
  value = aws_vpc.three_tier.id
}

output "web_subnet_ids" {
  value = [for s in aws_subnet.three_tier_web : s.id]
}

output "app_subnet_ids" {
  value = [for s in aws_subnet.three_tier_app : s.id]
}

output "db_subnet_ids" {
  value = [for s in aws_subnet.three_tier_db : s.id]
}
