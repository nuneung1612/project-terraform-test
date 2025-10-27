# Web ALB Security Group
resource "aws_security_group" "web_alb" {
  name        = "three-tier-web-alb-sg"
  description = "Allow HTTP inbound traffic for Web ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
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

# Web Instance Security Group
resource "aws_security_group" "web_instance" {
  name        = "three-tier-web-instance-sg"
  description = "Allow traffic from Web ALB and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from Web ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_alb.id]
  }

  ingress {
    description = "SSH from anywhere"
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


# Web Application Load Balancer
resource "aws_lb" "web" {
  name               = "three-tier-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_alb.id]
  subnets            = [for subnet in aws_subnet.web : subnet.id]

  tags = {
    Name = "three-tier-web-alb"
  }
}

# Web ALB Target Group
resource "aws_lb_target_group" "web" {
  name        = "three-tier-web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "three-tier-web-tg"
  }
}

# Web ALB Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Web Launch Template
resource "aws_launch_template" "web" {
  name_prefix   = "three-tier-web-"
  image_id      = var.ami-id
  instance_type = "t2.micro"
  key_name      = var.key-pair-name

  vpc_security_group_ids = [aws_security_group.web_instance.id]

  user_data = filebase64("${path.module}/user-data.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-web-instance"
    }
  }
}

# Web Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                = "three-tier-web-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  vpc_zone_identifier = [for subnet in aws_subnet.web : subnet.id]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]

  tag {
    key                 = "Name"
    value               = "three-tier-web-asg-instance"
    propagate_at_launch = true
  }
}
