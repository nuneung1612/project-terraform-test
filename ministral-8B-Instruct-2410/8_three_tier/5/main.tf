provider "aws" {
  region = var.aws_region
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Variables
variable "aws_region" {
  description = "The AWS region to deploy the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# Network Layer

# VPC
resource "aws_vpc" "three-tier-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "three-tier-vpc"
  }
}

# Subnets
resource "aws_subnet" "web_subnet_1" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "three-tier-web-subnet-1"
  }
}

resource "aws_subnet" "web_subnet_2" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "three-tier-web-subnet-2"
  }
}

resource "aws_subnet" "app_subnet_1" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "three-tier-app-subnet-1"
  }
}

resource "aws_subnet" "app_subnet_2" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "three-tier-app-subnet-2"
  }
}

resource "aws_subnet" "db_subnet_1" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "three-tier-db-subnet-1"
  }
}

resource "aws_subnet" "db_subnet_2" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "three-tier-db-subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "three-tier-igw" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-igw"
  }
}

# NAT Gateway
resource "aws_eip" "three-tier-nat-eip" {
  vpc = true
}

resource "aws_nat_gateway" "three-tier-nat-gateway" {
  allocation_id = aws_eip.three-tier-nat-eip.id
  subnet_id     = aws_subnet.app_subnet_1.id

  depends_on = [aws_internet_gateway.three-tier-igw]
}

# Route Tables
resource "aws_route_table" "web-route-table" {
  vpc_id = aws_vpc.three-tier-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.three-tier-igw.id
  }

  tags = {
    Name = "three-tier-web-route-table"
  }
}

resource "aws_route_table_association" "web-route-table-association-1" {
  subnet_id      = aws_subnet.web_subnet_1.id
  route_table_id = aws_route_table.web-route-table.id
}

resource "aws_route_table_association" "web-route-table-association-2" {
  subnet_id      = aws_subnet.web_subnet_2.id
  route_table_id = aws_route_table.web-route-table.id
}

resource "aws_route_table" "app-route-table" {
  vpc_id = aws_vpc.three-tier-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.three-tier-nat-gateway.id
  }

  tags = {
    Name = "three-tier-app-route-table"
  }
}

resource "aws_route_table_association" "app-route-table-association-1" {
  subnet_id      = aws_subnet.app_subnet_1.id
  route_table_id = aws_route_table.app-route-table.id
}

resource "aws_route_table_association" "app-route-table-association-2" {
  subnet_id      = aws_subnet.app_subnet_2.id
  route_table_id = aws_route_table.app-route-table.id
}

resource "aws_route_table_association" "db-route-table-association-1" {
  subnet_id      = aws_subnet.db_subnet_1.id
  route_table_id = aws_route_table.app-route-table.id
}

resource "aws_route_table_association" "db-route-table-association-2" {
  subnet_id      = aws_subnet.db_subnet_2.id
  route_table_id = aws_route_table.app-route-table.id
}

# Web Tier

# ALB
resource "aws_lb" "web-alb" {
  name               = "three-tier-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-alb-sg.id]
  subnets            = [aws_subnet.web_subnet_1.id, aws_subnet.web_subnet_2.id]
}

resource "aws_lb_target_group" "web-tg" {
  name     = "three-tier-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.three-tier-vpc.id
  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_lb.web-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
}

# Launch Template
resource "aws_launch_template" "web-lt" {
  name_prefix   = "three-tier-web-lt-"
  image_id      = "ami-052064a798f08f0d3"
  instance_type = "t2.micro"
  key_name      = "3-tier-key-pair"
  user_data     = filebase64("user-data.sh")

  network_interfaces {
    associate_public_ip_address = true
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "three-tier-web-lt"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web-asg" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.web_subnet_1.id, aws_subnet.web_subnet_2.id]
  launch_template {
    id      = aws_launch_template.web-lt.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  tags = {
    Name = "three-tier-web-asg"
  }
}

# Security Groups
resource "aws_security_group" "web-alb-sg" {
  name   = "three-tier-web-alb-sg"
  vpc_id = aws_vpc.three-tier-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_security_group" "web-instances-sg" {
  name   = "three-tier-web-instances-sg"
  vpc_id = aws_vpc.three-tier-vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-alb-sg.id]
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

# Application Tier

# ALB
resource "aws_lb" "app-alb" {
  name               = "three-tier-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app-alb-sg.id]
  subnets            = [aws_subnet.app_subnet_1.id, aws_subnet.app_subnet_2.id]
}

resource "aws_lb_target_group" "app-tg" {
  name     = "three-tier-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.three-tier-vpc.id
  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "app-listener" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-tg.arn
  }
}

# Launch Template
resource "aws_launch_template" "app-lt" {
  name_prefix   = "three-tier-app-lt-"
  image_id      = "ami-052064a798f08f0d3"
  instance_type = "t2.micro"
  key_name      = "3-tier-key-pair"
  user_data     = filebase64("user-data.sh")

  network_interfaces {
    associate_public_ip_address = false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "three-tier-app-lt"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app-asg" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.app_subnet_1.id, aws_subnet.app_subnet_2.id]
  launch_template {
    id      = aws_launch_template.app-lt.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  tags = {
    Name = "three-tier-app-asg"
  }
}

# Security Groups
resource "aws_security_group" "app-alb-sg" {
  name   = "three-tier-app-alb-sg"
  vpc_id = aws_vpc.three-tier-vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-instances-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app-instances-sg" {
  name   = "three-tier-app-instances-sg"
  vpc_id = aws_vpc.three-tier-vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app-alb-sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web-instances-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database Tier

# RDS MySQL Instance
resource "aws_db_subnet_group" "three-tier-db-subnet-group" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = [aws_subnet.db_subnet_1.id, aws_subnet.db_subnet_2.id]
}

resource "aws_db_instance" "mydb" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  name                   = "mydb"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.three-tier-db-subnet-group.name
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  apply_immediately      = true
  multi_az               = true
}

# Security Group for DB
resource "aws_security_group" "db-sg" {
  name   = "three-tier-db-sg"
  vpc_id = aws_vpc.three-tier-vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app-instances-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Outputs
output "web_asg_id" {
  value = aws_autoscaling_group.web-asg.id
}

output "app_asg_id" {
  value = aws_autoscaling_group.app-asg.id
}

output "rds_endpoint" {
  value = aws_db_instance.mydb.endpoint
}
