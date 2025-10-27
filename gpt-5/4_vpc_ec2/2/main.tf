// main.tf
locals {
  common_tags = {
    Environment = "demo"
  }
}

/* -----------------------------
   Networking: VPC & Subnets
--------------------------------*/
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "main-vpc"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "main-igw"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "public-subnet-us-east-1a"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(local.common_tags, {
    Name = "private-subnet-us-east-1a"
    Tier = "private"
  })
}

/* -----------------------------
   NAT Gateway & EIP
--------------------------------*/
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "nat-eip"
  })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = merge(local.common_tags, {
    Name = "main-nat-gateway"
  })

  depends_on = [aws_internet_gateway.igw]
}

/* -----------------------------
   Route Tables & Associations
--------------------------------*/
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "private-rt"
  })
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id

  depends_on = [aws_nat_gateway.nat]
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

/* -----------------------------
   Security Groups (VPC-level)
--------------------------------*/
resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Allow HTTP and SSH from anywhere; all outbound."
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "public-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "public_http" {
  security_group_id = aws_security_group.public_sg.id
  description       = "HTTP from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "public_ssh" {
  security_group_id = aws_security_group.public_sg.id
  description       = "SSH from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "public_all_egress" {
  security_group_id = aws_security_group.public_sg.id
  description       = "All outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Allow SSH only from within the VPC; all outbound."
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "private-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "private_ssh_from_vpc" {
  security_group_id = aws_security_group.private_sg.id
  description       = "SSH from within the VPC"
  cidr_ipv4         = var.vpc_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "private_all_egress" {
  security_group_id = aws_security_group.private_sg.id
  description       = "All outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

/* -----------------------------
   EC2 Instances
--------------------------------*/
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "bastion-public"
    Role = "bastion"
  })

  depends_on = [aws_route.public_internet]
}

resource "aws_instance" "private_host" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = merge(local.common_tags, {
    Name = "private-host"
    Role = "app"
  })

  depends_on = [aws_route.private_nat]
}
