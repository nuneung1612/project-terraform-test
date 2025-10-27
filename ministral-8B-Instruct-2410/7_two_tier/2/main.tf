provider "aws" {
  region  = "us-east-1"
  version = "~> 5.0"
}

# Network Configuration
resource "aws_vpc" "vpc_project" {
  cidr_block       = var.cidr_vpc
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

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc_project.id
  cidr_block              = var.cidr_public_subnet_1
  availability_zone       = var.web1_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc_project.id
  cidr_block              = var.cidr_public_subnet_2
  availability_zone       = var.web2_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc_project.id
  cidr_block        = var.cidr_private_subnet_1
  availability_zone = var.web1_az
  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc_project.id
  cidr_block        = var.cidr_private_subnet_2
  availability_zone = var.web2_az
  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_route_table" "project_rt" {
  vpc_id = aws_vpc.vpc_project.id
  tags = {
    Name = "project-rt"
  }
}

resource "aws_route" "project_rt_route" {
  route_table_id         = aws_route_table.project_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig_project.id
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.project_rt.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.project_rt.id
}

# Security Groups
resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Public security group"
  vpc_id      = aws_vpc.vpc_project.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Private security group"
  vpc_id      = aws_vpc.vpc_project.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "10.0.1.0/24"]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "ALB security group"
  vpc_id      = aws_vpc.vpc_project.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer Setup
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  tags = {
    Name = "alb"
  }
}

resource "aws_lb_target_group" "project_tg" {
  name     = "project-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_project.id
}

resource "aws_lb_target_group_attachment" "web1_attachment" {
  target_group_arn = aws_lb_target_group.project_tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2_attachment" {
  target_group_arn = aws_lb_target_group.project_tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project_tg.arn
  }
}

# EC2 Instances
resource "aws_instance" "web1" {
  ami               = var.ami
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = aws_subnet.public_subnet_1.id
  availability_zone = var.web1_az

  tags = {
    Name = "web1_instance"
  }

  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
}

resource "aws_instance" "web2" {
  ami               = var.ami
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = aws_subnet.public_subnet_2.id
  availability_zone = var.web2_az

  tags = {
    Name = "web2_instance"
  }

  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
}

# RDS Database
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

resource "aws_db_instance" "db_instance" {
  allocated_storage      = 10
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
}
