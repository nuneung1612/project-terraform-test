resource "aws_vpc" "vpc_project" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "vpc-project"
  }
}

resource "aws_internet_gateway" "ig_project" {
  vpc_id = aws_vpc.vpc_project.id

  tags = {
    Name = "ig-project"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.vpc_project.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.web1_az
  map_public_ip_on_launch = true

  tags = {
    Name = "public_1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.vpc_project.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.web2_az
  map_public_ip_on_launch = true

  tags = {
    Name = "public_2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.vpc_project.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.web1_az

  tags = {
    Name = "private_1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.vpc_project.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.web2_az

  tags = {
    Name = "private_2"
  }
}

resource "aws_route_table" "project_rt" {
  vpc_id = aws_vpc.vpc_project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig_project.id
  }

  tags = {
    Name = "project-rt"
  }
}

resource "aws_route_table_association" "public_1_rt_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.project_rt.id
}

resource "aws_route_table_association" "public_2_rt_assoc" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.project_rt.id
}

resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Security group for public instances"
  vpc_id      = aws_vpc.vpc_project.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-sg"
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Security group for private instances"
  vpc_id      = aws_vpc.vpc_project.id

  ingress {
    description = "MySQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description     = "MySQL from public security group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.vpc_project.id

  ingress {
    description = "All inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}