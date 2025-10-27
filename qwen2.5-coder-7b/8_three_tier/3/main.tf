provider "aws" {
  region  = var.region
  version = "~> 5.0"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "key_pair_name" {
  description = "Key pair name"
  default     = "3-tier-key-pair"
}

variable "ami_id" {
  description = "AMI ID"
  default     = "ami-052064a798f08f0d3"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "Subnet CIDRs"
  default = [
    "10.0.1.0/24", "10.0.2.0/24",
    "10.0.3.0/24", "10.0.4.0/24",
    "10.0.5.0/24", "10.0.6.0/24"
  ]
}

variable "azs" {
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "db_username" {
  description = "DB username"
  sensitive   = true
}

variable "db_password" {
  description = "DB password"
  sensitive   = true
}

variable "db_storage_size" {
  description = "DB storage size"
  default     = "10"
}

variable "db_instance_class" {
  description = "DB instance class"
  default     = "db.t3.micro"
}

variable "db_engine" {
  description = "DB engine"
  default     = "mysql"
}

variable "db_engine_version" {
  description = "DB engine version"
  default     = "5.7"
}

variable "db_multi_az" {
  description = "Enable multi-AZ deployment"
  default     = true
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  default     = "three-tier-db-subnet-group"
}

variable "alb_health_check_path" {
  description = "ALB health check path"
  default     = "/"
}

variable "alb_health_check_matcher" {
  description = "ALB health check matcher"
  default     = "200"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_subnet" "web_public" {
  count                   = length(var.subnet_cidrs) / 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.subnet_cidrs, count.index * 2)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = format("three-tier-web-public-%s", element(var.azs, count.index))
  }
}

resource "aws_subnet" "app_private" {
  count                   = length(var.subnet_cidrs) / 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.subnet_cidrs, count.index * 2 + 1)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = format("three-tier-app-private-%s", element(var.azs, count.index))
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "three-tier-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "three-tier-public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "three-tier-private-rt"
  }
}

resource "aws_route_table_association" "web_public_assoc" {
  count          = length(aws_subnet.web_public)
  subnet_id      = element(aws_subnet.web_public[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "app_private_assoc" {
  count          = length(aws_subnet.app_private)
  subnet_id      = element(aws_subnet.app_private[*].id, count.index)
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "three-tier-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.app_private[0].id
  tags = {
    Name = "three-tier-nat-gw"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_security_group" "web_alb_sg" {
  vpc_id = aws_vpc.main.id
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
  tags = {
    Name = "three-tier-web-alb-sg"
  }
}

resource "aws_security_group" "web_instances_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.web_alb_sg.id
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
  tags = {
    Name = "three-tier-web-instances-sg"
  }
}

resource "aws_security_group" "app_alb_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.web_instances_sg.id
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "three-tier-app-alb-sg"
  }
}

resource "aws_security_group" "app_instances_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.app_alb_sg.id
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
  tags = {
    Name = "three-tier-app-instances-sg"
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.app_instances_sg.id
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "three-tier-db-sg"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = aws_subnet.app_private[*].id
  tags = {
    Name = var.db_subnet_group_name
  }
}

resource "aws_launch_template" "web_lt" {
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_pair_name
  user_data     = filebase64("${path.module}/user-data.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-web-instance"
    }
  }
}

resource "aws_launch_template" "app_lt" {
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_pair_name
  user_data     = filebase64("${path.module}/user-data.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-app-instance"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  launch_template     = aws_launch_template.web_lt.id
  min_size            = 1
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = aws_subnet.web_public[*].id
  load_balancers      = [aws_lb.web.id]
  health_check_type   = "EC2"
  target_group_arns   = [aws_target_group.web_tg.arn]

  tag {
    key                 = "Name"
    value               = "three-tier-web-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_asg" {
  launch_template     = aws_launch_template.app_lt.id
  min_size            = 1
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = aws_subnet.app_private[*].id
  load_balancers      = [aws_lb.app.id]
  health_check_type   = "EC2"
  target_group_arns   = [aws_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "three-tier-app-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "web" {
  internal        = false
  name            = "three-tier-web-lb"
  security_groups = [aws_security_group.web_alb_sg.id]
  subnets         = aws_subnet.web_public[*].id

  listener {
    port     = 80
    protocol = "HTTP"
    default_action {
      type = "forward"
      forward {
        target_group_arn = aws_target_group.web_tg.arn
      }
    }
  }

  tags = {
    Name = "three-tier-web-lb"
  }
}

resource "aws_lb" "app" {
  internal        = false
  name            = "three-tier-app-lb"
  security_groups = [aws_security_group.app_alb_sg.id]
  subnets         = aws_subnet.app_private[*].id

  listener {
    port     = 80
    protocol = "HTTP"
    default_action {
      type = "forward"
      forward {
        target_group_arn = aws_target_group.app_tg.arn
      }
    }
  }

  tags = {
    Name = "three-tier-app-lb"
  }
}

resource "aws_target_group" "web_tg" {
  name     = "three-tier-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = var.alb_health_check_path
    matcher             = var.alb_health_check_matcher
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "three-tier-web-tg"
  }
}

resource "aws_target_group" "app_tg" {
  name     = "three-tier-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = var.alb_health_check_path
    matcher             = var.alb_health_check_matcher
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "three-tier-app-tg"
  }
}

resource "aws_db_instance" "db" {
  identifier             = "three-tier-db"
  allocated_storage      = var.db_storage_size
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name

  tags = {
    Name = "three-tier-db"
  }
}
