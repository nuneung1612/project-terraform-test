terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}

# Variables
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

# Data sources
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Network Layer
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_subnet" "web_public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "three-tier-web-public-${count.index}"
  }
}

resource "aws_subnet" "web_private" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-web-private-${count.index}"
  }
}

resource "aws_subnet" "app_private" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 4)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-app-private-${count.index}"
  }
}

resource "aws_subnet" "db_private" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 6)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "three-tier-db-private-${count.index}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "three-tier-igw"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = 2
  subnet_id     = element(aws_subnet.app_private[*].id, count.index)
  allocation_id = aws_eip.nat[count.index].id
  tags = {
    Name = "three-tier-nat-${count.index}"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat" {
  count = 2
  vpc   = true
  tags = {
    Name = "three-tier-nat-eip-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "three-tier-public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  count                  = 2
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_internet_gateway.igw]
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = element(aws_subnet.web_public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "three-tier-private-rt-${count.index}"
  }
}

resource "aws_route" "private_nat_access" {
  count                  = 2
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.app_private[*].id, count.index)
  route_table_id = aws_route_table.private[count.index].id
}

# Web Tier
resource "aws_lb" "web_alb" {
  name               = "three-tier-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.web_public[*].id
}

resource "aws_security_group" "alb" {
  name        = "three-tier-alb-sg"
  description = "Security group for ALB"
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

resource "aws_security_group" "web_instances" {
  name        = "three-tier-web-instances-sg"
  description = "Security group for web instances"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
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
  name_prefix   = "three-tier-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "3-tier-key-pair"

  user_data = filebase64("user-data.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-web-instance"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 1
  vpc_zone_identifier       = aws_subnet.web_private[*].id
  launch_template           = aws_launch_template.web.id
  health_check_type         = "EC2"
  health_check_grace_period = 300
  health_check_path         = "/"
  health_check_port         = "80"
  health_check_protocol     = "HTTP"
  health_check_matcher      = "200"

  tags = {
    Name = "three-tier-web-asg"
  }
}

# Application Tier
resource "aws_lb" "app_alb" {
  name               = "three-tier-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_alb.id]
  subnets            = aws_subnet.web_public[*].id
}

resource "aws_security_group" "app_alb" {
  name        = "three-tier-app-alb-sg"
  description = "Security group for app ALB"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_instances.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_instances" {
  name        = "three-tier-app-instances-sg"
  description = "Security group for app instances"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app_alb.id]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_instances.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "three-tier-app-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "3-tier-key-pair"

  user_data = filebase64("user-data.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-app-instance"
    }
  }
}

resource "aws_autoscaling_group" "app" {
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 1
  vpc_zone_identifier       = aws_subnet.app_private[*].id
  launch_template           = aws_launch_template.app.id
  health_check_type         = "EC2"
  health_check_grace_period = 300
  health_check_path         = "/"
  health_check_port         = "80"
  health_check_protocol     = "HTTP"
  health_check_matcher      = "200"

  tags = {
    Name = "three-tier-app-asg"
  }
}

# Database Tier
resource "aws_db_subnet_group" "db" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = aws_subnet.db_private[*].id
}

resource "aws_rds_cluster" "mydb" {
  cluster_identifier      = "three-tier-mydb"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.09.2"
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 5
  apply_immediately       = true
  skip_final_snapshot     = true

  db_subnet_group_name = aws_db_subnet_group.db.name

  tags = {
    Name = "three-tier-mydb"
  }
}

resource "aws_security_group" "db" {
  name        = "three-tier-db-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_instances.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_rds_cluster_instance" "mydb" {
  count               = 2
  identifier          = "three-tier-mydb-instance-${count.index}"
  cluster_identifier  = aws_rds_cluster.mydb.id
  instance_class      = "db.t3.micro"
  engine              = aws_rds_cluster.mydb.engine
  engine_version      = aws_rds_cluster.mydb.engine_version
  publicly_accessible = false
  apply_immediately   = true

  tags = {
    Name = "three-tier-mydb-instance-${count.index}"
  }
}
