provider "aws" {
  region = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "web_subnets" {
  description = "List of web subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_subnets" {
  description = "List of app subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db_subnets" {
  description = "List of db subnets"
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "ami_id" {
  description = "AMI ID"
  default     = "ami-052064a798f08f0d3"
}

variable "key_pair_name" {
  description = "Key pair name"
  default     = "3-tier-key-pair"
}

variable "db_username" {
  description = "DB username"
  type        = string
}

variable "db_password" {
  description = "DB password"
  type        = string
  sensitive   = true
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_subnet" "web" {
  count                   = length(var.web_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.web_subnets, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  tags = {
    Name = "three-tier-web-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "app" {
  count             = length(var.app_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.app_subnets, count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags = {
    Name = "three-tier-app-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "db" {
  count             = length(var.db_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.db_subnets, count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags = {
    Name = "three-tier-db-subnet-${count.index + 1}"
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

resource "aws_route_table_association" "public_web" {
  count          = length(aws_subnet.web)
  subnet_id      = element(aws_subnet.web[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = element(aws_subnet.app[*].id, 0)
  tags = {
    Name = "three-tier-nat-gateway"
  }
  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "main" {
  vpc = true
  tags = {
    Name = "three-tier-eip"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "three-tier-private-route-table"
  }
}

resource "aws_route_table_association" "private_app" {
  count          = length(aws_subnet.app)
  subnet_id      = element(aws_subnet.app[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

# Network Layer ends here

# Web Tier starts here

resource "aws_security_group" "alb_web" {
  name        = "three-tier-alb-web-sg"
  description = "Allow HTTP traffic from the internet"
  vpc_id      = aws_vpc.main.id
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

resource "aws_security_group" "instances_web" {
  name        = "three-tier-instances-web-sg"
  description = "Allow HTTP from ALB and SSH from anywhere"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.alb_web.id
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

resource "aws_launch_template" "web" {
  name_prefix = "three-tier-launch-template-web-"

  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_pair_name

  user_data_base64 = base64encode(file("user-data.sh"))

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-instance"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "three-tier-volume"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "three-tier-autoscaling-group-web"
  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 2
  launch_template           = aws_launch_template.web.id
  vpc_zone_identifier       = concat(aws_subnet.web[*].id)
  load_balancers            = [aws_lb.web.id]
  target_group_arns         = [aws_target_group.web.id]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "three-tier-autoscaling-group-web"
    propagate_at_launch = true
  }
}

resource "aws_lb" "web" {
  name               = "three-tier-lb-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_web.id]

  subnet_mappings {
    subnet_id = element(aws_subnet.web[*].id, 0)
  }
  subnet_mappings {
    subnet_id = element(aws_subnet.web[*].id, 1)
  }

  tags = {
    Name = "three-tier-lb-web"
  }
}

resource "aws_target_group" "web" {
  name     = "three-tier-target-group-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Web Tier ends here

# Application Tier starts here

resource "aws_security_group" "alb_app" {
  name        = "three-tier-alb-app-sg"
  description = "Allow HTTP traffic from web tier security group"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.instances_web.id
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "instances_app" {
  name        = "three-tier-instances-app-sg"
  description = "Allow HTTP from ALB and SSH from web tier instances"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.alb_app.id
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

resource "aws_launch_template" "app" {
  name_prefix = "three-tier-launch-template-app-"

  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_pair_name

  user_data_base64 = base64encode(file("user-data.sh"))

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-instance"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "three-tier-volume"
    }
  }
}

resource "aws_autoscaling_group" "app" {
  name                      = "three-tier-autoscaling-group-app"
  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 2
  launch_template           = aws_launch_template.app.id
  vpc_zone_identifier       = concat(aws_subnet.app[*].id)
  load_balancers            = [aws_lb.app.id]
  target_group_arns         = [aws_target_group.app.id]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "three-tier-autoscaling-group-app"
    propagate_at_launch = true
  }
}

resource "aws_lb" "app" {
  name               = "three-tier-lb-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_app.id]

  subnet_mappings {
    subnet_id = element(aws_subnet.app[*].id, 0)
  }
  subnet_mappings {
    subnet_id = element(aws_subnet.app[*].id, 1)
  }

  tags = {
    Name = "three-tier-lb-app"
  }
}

resource "aws_target_group" "app" {
  name     = "three-tier-target-group-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Application Tier ends here

# Database Tier starts here

resource "aws_db_subnet_group" "db" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = aws_subnet.db[*].id
  tags = {
    Name = "three-tier-db-subnet-group"
  }
}

resource "aws_rds_cluster" "db" {
  cluster_identifier      = "three-tier-rds-cluster"
  engine                  = "mysql"
  engine_version          = "5.7"
  master_username         = var.db_username
  master_password         = var.db_password
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.db.name
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = [aws_security_group.instances_app.id]

  tag {
    key                 = "Name"
    value               = "three-tier-rds-cluster"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "db" {
  name        = "three-tier-db-sg"
  description = "Allow MySQL traffic from app tier security group only"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.instances_app.id
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database Tier ends here
