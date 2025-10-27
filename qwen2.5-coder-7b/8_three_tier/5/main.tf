provider "aws" {
  region  = var.region
  version = "~> 5.0"
}

variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  default     = "10.0.0.0/16"
}

variable "subnet_public_web_a" {
  description = "Public Web Subnet A CIDR Block"
  default     = "10.0.1.0/24"
}

variable "subnet_public_web_b" {
  description = "Public Web Subnet B CIDR Block"
  default     = "10.0.2.0/24"
}

variable "subnet_private_app_a" {
  description = "Private App Subnet A CIDR Block"
  default     = "10.0.3.0/24"
}

variable "subnet_private_app_b" {
  description = "Private App Subnet B CIDR Block"
  default     = "10.0.4.0/24"
}

variable "subnet_private_db_a" {
  description = "Private DB Subnet A CIDR Block"
  default     = "10.0.5.0/24"
}

variable "subnet_private_db_b" {
  description = "Private DB Subnet B CIDR Block"
  default     = "10.0.6.0/24"
}

variable "key_name" {
  description = "Key Pair Name"
  default     = "3-tier-key-pair"
}

variable "ami_id" {
  description = "AMI ID"
  default     = "ami-052064a798f08f0d3"
}

variable "db_username" {
  description = "DB Username"
  sensitive   = true
}

variable "db_password" {
  description = "DB Password"
  sensitive   = true
}

# Network Configuration
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_subnet" "public_web_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public_web_a
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "three-tier-public-web-a"
  }
}

resource "aws_subnet" "public_web_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public_web_b
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "three-tier-public-web-b"
  }
}

resource "aws_subnet" "private_app_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_app_a
  availability_zone = "us-east-1a"

  tags = {
    Name = "three-tier-private-app-a"
  }
}

resource "aws_subnet" "private_app_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_app_b
  availability_zone = "us-east-1b"

  tags = {
    Name = "three-tier-private-app-b"
  }
}

resource "aws_subnet" "private_db_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_db_a
  availability_zone = "us-east-1a"

  tags = {
    Name = "three-tier-private-db-a"
  }
}

resource "aws_subnet" "private_db_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_db_b
  availability_zone = "us-east-1b"

  tags = {
    Name = "three-tier-private-db-b"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "three-tier-internet-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "three-tier-public-route-table"
  }
}

resource "aws_route_table_association" "public_web_a" {
  subnet_id      = aws_subnet.public_web_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_web_b" {
  subnet_id      = aws_subnet.public_web_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "three-tier-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id     = aws_eip.nat.id
  subnet_id         = aws_subnet.private_app_a.id
  connectivity_type = "public"

  tags = {
    Name = "three-tier-nat-gateway"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block              = "0.0.0.0/0"
    nat_gateway_id          = aws_nat_gateway.main.id
    dependent_service_cidrs = ["com.amazonaws.us-east-1.ec2"]
  }

  tags = {
    Name = "three-tier-private-route-table"
  }
}

resource "aws_route_table_association" "private_app_a" {
  subnet_id      = aws_subnet.private_app_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_app_b" {
  subnet_id      = aws_subnet.private_app_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db_a" {
  subnet_id      = aws_subnet.private_db_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db_b" {
  subnet_id      = aws_subnet.private_db_b.id
  route_table_id = aws_route_table.private.id
}

# Security Groups
resource "aws_security_group" "alb_web" {
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
    Name = "three-tier-alb-web-sg"
  }
}

resource "aws_security_group" "instances_web" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    sg_ids    = [aws_security_group.alb_web.id]
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
    Name = "three-tier-instances-web-sg"
  }
}

resource "aws_security_group" "alb_app" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    sg_ids    = [aws_security_group.instances_web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-alb-app-sg"
  }
}

resource "aws_security_group" "instances_app" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    sg_ids    = [aws_security_group.alb_app.id]
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
    Name = "three-tier-instances-app-sg"
  }
}

resource "aws_security_group" "instances_db" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    sg_ids    = [aws_security_group.instances_app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-instances-db-sg"
  }
}

# Launch Templates
data "template_file" "web_user_data" {
  template = file("user-data.sh")

  vars = {
    key_name = var.key_name
    db_host  = aws_rds_cluster_instance.db[0].endpoint
    db_user  = var.db_username
    db_pass  = var.db_password
  }
}

resource "aws_launch_template" "web" {
  name_prefix = "three-tier-launch-template-web-"

  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  user_data = data.template_file.web_user_data.rendered

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "three-tier-instance-web"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "three-tier-volume-web"
    }
  }
}

resource "aws_launch_template" "app" {
  name_prefix = "three-tier-launch-template-app-"

  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  user_data = data.template_file.web_user_data.rendered

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "three-tier-instance-app"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "three-tier-volume-app"
    }
  }
}

# Auto Scaling Groups
resource "aws_autoscaling_group" "web" {
  name                = "three-tier-asg-web"
  launch_template     = aws_launch_template.web.latest_version
  min_size            = 1
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.public_web_a.id, aws_subnet.public_web_b.id]
  load_balancers      = [aws_lb.main.id]
  target_group_arns   = [aws_target_group.web.id]

  tag {
    key                 = "Name"
    value               = "three-tier-asg-web"
    propagate_at_launch = true
  }

  depends_on = [
    aws_lb_listener.listener_http,
    aws_lb_target_group.web
  ]
}

resource "aws_autoscaling_group" "app" {
  name                = "three-tier-asg-app"
  launch_template     = aws_launch_template.app.latest_version
  min_size            = 1
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.private_app_a.id, aws_subnet.private_app_b.id]
  load_balancers      = [aws_lb.main.id]
  target_group_arns   = [aws_target_group.app.id]

  tag {
    key                 = "Name"
    value               = "three-tier-asg-app"
    propagate_at_launch = true
  }

  depends_on = [
    aws_lb_listener.listener_http,
    aws_lb_target_group.app
  ]
}

# Load Balancers
resource "aws_lb" "main" {
  name               = "three-tier-lb-main"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_web.id]
  subnets            = [aws_subnet.public_web_a.id, aws_subnet.public_web_b.id]

  tags = {
    Name = "three-tier-lb-main"
  }
}

resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_target_group.web.arn
  }
}

resource "aws_lb_target_group" "web" {
  name     = "three-tier-tg-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tag {
    key                 = "Name"
    value               = "three-tier-tg-web"
    propagate_at_launch = true
  }
}

resource "aws_lb_target_group" "app" {
  name     = "three-tier-tg-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tag {
    key                 = "Name"
    value               = "three-tier-tg-app"
    propagate_at_launch = true
  }
}

# RDS Database
resource "aws_db_subnet_group" "main" {
  name       = "three-tier-rds-subnet-group"
  subnet_ids = [aws_subnet.private_db_a.id, aws_subnet.private_db_b.id]

  tags = {
    Name = "three-tier-rds-subnet-group"
  }
}

resource "aws_rds_cluster" "main" {
  cluster_identifier      = "three-tier-rds-cluster"
  engine                  = "mysql"
  engine_mode             = "serverless"
  engine_version          = "5.7.mysql_aurora.2.09.1"
  master_username         = var.db_username
  master_password         = var.db_password
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.main.name
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"

  scaling_configuration {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 16
    seconds_until_auto_pause = 300
    seconds_before_timeout   = 300
    timeout_action           = "force_apply_capacity_change_without_recovery"
  }

  vpc_security_group_ids = [aws_security_group.instances_db.id]

  tag {
    key                 = "Name"
    value               = "three-tier-rds-cluster"
    propagate_at_launch = true
  }
}
