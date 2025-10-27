provider "aws" {
  region  = "us-east-1"
  version = "~> 5.0"
}

variable "vpc-cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "subnet-public-cidrs" {
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "subnet-app-cidrs" {
  description = "CIDR blocks for app subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "subnet-db-cidrs" {
  description = "CIDR blocks for db subnets"
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "key-name" {
  description = "Key pair name"
  default     = "3-tier-key-pair"
}

variable "ami-id" {
  description = "AMI ID"
  default     = "ami-052064a798f08f0d3"
}

variable "db-username" {
  description = "DB username"
  type        = string
}

variable "db-password" {
  description = "DB password"
  type        = string
  sensitive   = true
}

variable "db-storage-size" {
  description = "DB storage size in GB"
  default     = 10
}

variable "db-instance-class" {
  description = "DB instance class"
  default     = "db.t3.micro"
}

variable "db-multi-az" {
  description = "Enable multi-AZ deployment"
  default     = true
}

variable "db-skip-final-snapshot" {
  description = "Skip final snapshot for RDS"
  default     = true
}

variable "alb-health-check-path" {
  description = "Health check path for ALB"
  default     = "/"
}

variable "alb-health-check-matcher" {
  description = "Health check matcher for ALB"
  default     = 200
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc-cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.subnet-public-cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.subnet-public-cidrs, count.index)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "three-tier-subnet-public-${count.index + 1}"
  }
}

resource "aws_subnet" "app" {
  count             = length(var.subnet-app-cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.subnet-app-cidrs, count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)

  tags = {
    Name = "three-tier-subnet-app-${count.index + 1}"
  }
}

resource "aws_subnet" "db" {
  count             = length(var.subnet-db-cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.subnet-db-cidrs, count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)

  tags = {
    Name = "three-tier-subnet-db-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "three-tier-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "three-tier-route-table-public"
  }
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = "three-tier-route-table-app"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "app" {
  count          = length(aws_subnet.app)
  subnet_id      = element(aws_subnet.app[*].id, count.index)
  route_table_id = aws_route_table.app.id
}

resource "aws_eip" "nat-eip" {
  vpc = true

  tags = {
    Name = "three-tier-nat-eip"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.app[0].id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "three-tier-nat-gateway"
  }
}

resource "aws_security_group" "web-alb" {
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

resource "aws_security_group" "web-instances" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-alb.name]
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

resource "aws_launch_template" "web" {
  name_prefix = "three-tier-launch-template-web-"

  image_id      = var.ami-id
  instance_type = "t2.micro"
  key_name      = var.key-name

  user_data = filebase64("${path.module}/user-data.sh")

  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_version       = "HTTP/1.1"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }

  security_groups = [aws_security_group.web-instances.name]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "three-tier-web-instance"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "three-tier-autoscaling-group-web"
  launch_template     = aws_launch_template.web.latest_version
  min_size            = 1
  desired_capacity    = 2
  max_size            = 4
  vpc_zone_identifier = concat(aws_subnet.public[*].id)
  target_group_arns   = [aws_lb_target_group.web.arn]

  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "three-tier-web-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "app-alb" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-instances.name]
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

resource "aws_security_group" "app-instances" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app-alb.name]
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

resource "aws_launch_template" "app" {
  name_prefix = "three-tier-launch-template-app-"

  image_id      = var.ami-id
  instance_type = "t2.micro"
  key_name      = var.key-name

  user_data = filebase64("${path.module}/user-data.sh")

  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_version       = "HTTP/1.1"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }

  security_groups = [aws_security_group.app-instances.name]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "three-tier-app-instance"
    }
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "three-tier-autoscaling-group-app"
  launch_template     = aws_launch_template.app.latest_version
  min_size            = 1
  desired_capacity    = 2
  max_size            = 4
  vpc_zone_identifier = concat(aws_subnet.app[*].id)
  target_group_arns   = [aws_lb_target_group.app.arn]

  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "three-tier-app-asg"
    propagate_at_launch = true
  }
}

resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = aws_subnet.db[*].id

  tags = {
    Name = "three-tier-db-subnet-group"
  }
}

resource "aws_db_instance" "db" {
  identifier             = "three-tier-rds-db"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.db-instance-class
  allocated_storage      = var.db-storage-size
  username               = var.db-username
  password               = var.db-password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = var.db-skip-final-snapshot
  multi_az               = var.db-multi-az
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.name
  vpc_security_group_ids = [aws_security_group.db-instances.id]

  tags = {
    Name = "three-tier-rds-db"
  }
}

resource "aws_security_group" "db-instances" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app-instances.name]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-db-instances-sg"
  }
}

resource "aws_lb" "web" {
  name               = "three-tier-lb-web"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id

  security_groups = [aws_security_group.web-alb.name]

  tags = {
    Name = "three-tier-lb-web"
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_target_group" "web" {
  name     = "three-tier-tg-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = var.alb-health-check-path
    matcher             = var.alb-health-check-matcher
    interval_seconds    = 30
    timeout_seconds     = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "three-tier-tg-web"
  }
}

resource "aws_lb" "app" {
  name               = "three-tier-lb-app"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.app[*].id

  security_groups = [aws_security_group.app-alb.name]

  tags = {
    Name = "three-tier-lb-app"
  }
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group" "app" {
  name     = "three-tier-tg-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = var.alb-health-check-path
    matcher             = var.alb-health-check-matcher
    interval_seconds    = 30
    timeout_seconds     = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "three-tier-tg-app"
  }
}
