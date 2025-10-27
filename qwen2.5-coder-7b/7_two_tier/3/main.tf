provider "aws" {
  version = "~> 5.0"
  region  = "us-east-1"
}

variable "web1_az" {
  description = "Availability Zone for Web1"
  default     = "us-east-1a"
}

variable "web2_az" {
  description = "Availability Zone for Web2"
  default     = "us-east-1b"
}

variable "public_1_cidr" {
  description = "CIDR Block for Public Subnet 1"
  default     = "10.0.1.0/24"
}

variable "public_2_cidr" {
  description = "CIDR Block for Public Subnet 2"
  default     = "10.0.2.0/24"
}

variable "private_1_cidr" {
  description = "CIDR Block for Private Subnet 1"
  default     = "10.0.3.0/24"
}

variable "private_2_cidr" {
  description = "CIDR Block for Private Subnet 2"
  default     = "10.0.4.0/24"
}

variable "ami_id" {
  description = "AMI ID for EC2 Instances"
  default     = "ami-0360c520857e3138f"
}

variable "key_name" {
  description = "Key Pair Name for EC2 Instances"
  default     = "2-tier-key-pair"
}

variable "instance_type" {
  description = "Instance Type for EC2 Instances"
  default     = "t2.micro"
}

variable "engine" {
  description = "DB Engine for RDS"
  default     = "mysql"
}

variable "engine_version" {
  description = "DB Engine Version for RDS"
  default     = "8.0.39"
}

variable "instance_class" {
  description = "Instance Class for RDS"
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database Name for RDS"
  default     = "twotierdatabase"
}

variable "username" {
  description = "Username for RDS"
  sensitive   = true
}

variable "password" {
  description = "Password for RDS"
  sensitive   = true
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "vpc-project"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ig-project"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_1_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.web1_az

  tags = {
    Name = "public_1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_2_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.web2_az

  tags = {
    Name = "public_2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_1_cidr
  availability_zone = var.web1_az

  tags = {
    Name = "private_1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_2_cidr
  availability_zone = var.web2_az

  tags = {
    Name = "private_2"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "project-rt"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id

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

  tags = {
    Name = "public-sg"
  }
}

resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.name]
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
    Name = "private-sg"
  }
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id

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

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_lb" "main" {
  name            = "alb"
  internal        = false
  security_groups = [aws_security_group.alb_sg.id]
  subnets         = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  load_balancer_type = "application"

  depends_on = [aws_vpc.main]
}

resource "aws_target_group" "main" {
  name     = "project-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  depends_on = [aws_lb.main]
}

resource "aws_autoscaling_group" "web" {
  name                = "web-group"
  launch_template     = aws_launch_template.web.id
  min_size            = 2
  max_size            = 2
  desired_capacity    = 2
  health_check_type   = "ELB"
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  load_balancer_names = [aws_lb.main.name]
  target_group_arns   = [aws_target_group.main.arn]

  tag {
    key                 = "Name"
    value               = "web_instance"
    propagate_at_launch = true
  }

  depends_on = [aws_lb.main, aws_target_group.main]
}

resource "aws_launch_template" "web" {
  name_prefix        = "web-template-"
  image_id           = var.ami_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  security_group_ids = [aws_security_group.public_sg.id]

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {}))

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 8
      delete_on_termination = true
    }
  }

  depends_on = [aws_security_group.public_sg]
}

resource "aws_db_subnet_group" "main" {
  name       = "db-subnet"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

resource "aws_db_instance" "main" {
  identifier             = "db-instance"
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  parameter_group_name   = "default.mysql8.0"
  allocated_storage      = 10
  skip_final_snapshot    = true

  depends_on = [aws_db_subnet_group.main, aws_security_group.private_sg]
}
