# main.tf
provider "aws" {
  region = var.region
}

locals {
  name_prefix = "nfw" # short, descriptive prefix for Name tags
  tags        = var.common_tags
}

# -------------------------
# Networking - VPC & Subnets
# -------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-subnet-public-${var.availability_zone}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-subnet-private-${var.availability_zone}"
    Tier = "private"
  })
}

# -------------------------
# NAT Gateway + EIP
# -------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-eip-nat"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  # Not strictly required, but ensures IGW is attached before NAT creation in some accounts
  depends_on = [aws_internet_gateway.this]

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-natgw"
  })
}

# -------------------------
# Route Tables & Associations
# -------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-rtb-public"
  })
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-rtb-private"
  })
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# -------------------------
# Security Groups
# -------------------------
resource "aws_security_group" "public_sg" {
  name        = "${local.name_prefix}-sg-public"
  description = "Allow HTTP (80) and SSH (22) from anywhere; all egress"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-sg-public"
  })
}

resource "aws_security_group" "private_sg" {
  name        = "${local.name_prefix}-sg-private"
  description = "Allow SSH from within VPC CIDR; all egress"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-sg-private"
  })
}

# -------------------------
# EC2 Instances
# -------------------------
data "aws_ami" "provided" {
  # Placeholder data reference pattern; using explicit AMI from var.ami_id
  # This data block can be used for validation flows if extended later.
  most_recent = false
  owners      = ["self", "amazon"]
  filter {
    name   = "image-id"
    values = [var.ami_id]
  }
}

# Public (bastion/jump) instance
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-ec2-bastion-public"
    Role = "bastion"
    Tier = "public"
  })

  depends_on = [
    aws_route_table_association.public_assoc
  ]
}

# Private instance
resource "aws_instance" "private_app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = var.ssh_key_name

  # Do NOT associate a public IP in private subnet
  associate_public_ip_address = false

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-ec2-app-private"
    Role = "app"
    Tier = "private"
  })

  depends_on = [
    aws_route_table_association.private_assoc,
    aws_route.private_nat
  ]
}
