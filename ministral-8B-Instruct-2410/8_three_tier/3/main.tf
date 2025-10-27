provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
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

variable "key_pair_name" {
  description = "Name of the key pair"
  default     = "three-tier-key-pair"
}

variable "ami_id" {
  description = "AMI ID for the instances"
  default     = "ami-052064a798f08f0d3"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "three-tier-igw"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.private.0.id
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  tags = {
    Name = "three-tier-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(["10.0.3.0/24", "10.0.4.0/24"], count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags = {
    Name = "three-tier-private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "db" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(["10.0.5.0/24", "10.0.6.0/24"], count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags = {
    Name = "three-tier-db-subnet-${count.index + 1}"
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

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "three-tier-private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_db_subnet_group" "db" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = aws_subnet.db[*].id
}

resource "aws_security_group" "alb_web" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "three-tier-alb-web-sg"
  }
}

resource "aws_security_group" "web_instance" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_web.id]
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
    Name = "three-tier-web-instance-sg"
  }
}

resource "aws_security_group" "alb_app" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_web.id]
  }
  tags = {
    Name = "three-tier-alb-app-sg"
  }
}

resource "aws_security_group" "app_instance" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_app.id]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_instance.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "three-tier-app-instance-sg"
  }
}

resource "aws_security_group" "db" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_instance.id]
  }
  tags = {
    Name = "three-tier-db-sg"
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "three-tier-web-"
  image_id      = var.ami_id
  key_name      = var.key_pair_name
  instance_type = "t2.micro"
  user_data     = filebase64("user-data.sh")

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_instance.id]
  }

  tags = {
    Name = "three-tier-web-launch-template"
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "three-tier-app-"
  image_id      = var.ami_id
  key_name      = var.key_pair_name
  instance_type = "t2.micro"
  user_data     = filebase64("user-data.sh")

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app_instance.id]
  }

  tags = {
    Name = "three-tier-app-launch-template"
  }
}

resource "aws_autoscaling_group" "web" {
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 1
  vpc_zone_identifier       = aws_subnet.public[*].id
  launch_template           = aws_launch_template.web.id
  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "three-tier-web-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "app" {
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 1
  vpc_zone_identifier       = aws_subnet.private[*].id
  launch_template           = aws_launch_template.app.id
  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "three-tier-app-asg"
    propagate_at_launch = true
  }
}

resource "aws_elb" "web" {
  name            = "three-tier-web-alb"
  security_groups = [aws_security_group.alb_web.id]
  subnets         = aws_subnet.public[*].id
  internal        = false
  idle_timeout    = 60
  connection_settings {
    idle_timeout = 60
  }
  access_logs {
    bucket  = "your-log-bucket"
    prefix  = "web-logs"
    enabled = true
  }
  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_elb_target_group" "web" {
  name     = "three-tier-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_elb_listener" "web" {
  load_balancer_arn = aws_elb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_elb_target_group.web.arn
  }
}

resource "aws_elb" "app" {
  name            = "three-tier-app-alb"
  security_groups = [aws_security_group.alb_app.id]
  subnets         = aws_subnet.private[*].id
  internal        = false
  idle_timeout    = 60
  connection_settings {
    idle_timeout = 60
  }
  access_logs {
    bucket  = "your-log-bucket"
    prefix  = "app-logs"
    enabled = true
  }
  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_elb_target_group" "app" {
  name     = "three-tier-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_elb_listener" "app" {
  load_balancer_arn = aws_elb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_elb_target_group.app.arn
  }
}

resource "aws_rds_cluster" "mydb" {
  cluster_identifier      = "three-tier-mydb"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.08.2"
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 5
  storage_encrypted       = true
  db_subnet_group_name    = aws_db_subnet_group.db.name
  skip_final_snapshot     = true
  apply_immediately       = true

  tags = {
    Name = "three-tier-mydb"
  }
}

resource "aws_rds_cluster_instance" "mydb" {
  count              = 2
  identifier         = "three-tier-mydb-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.mydb.id
  instance_class     = "db.t3.micro"
  engine             = aws_rds_cluster.mydb.engine
  engine_version     = aws_rds_cluster.mydb.engine_version
  apply_immediately  = true
}
