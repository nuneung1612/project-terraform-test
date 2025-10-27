# App ALB Security Group
resource "aws_security_group" "app_alb" {
  name        = "three-tier-app-alb-sg"
  description = "Allow HTTP from web tier security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from Web Tier Instances"
    from_port       = 80
    to_port         = 80
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
    Name = "three-tier-app-alb-sg"
  }
}

# App Instance Security Group
resource "aws_security_group" "app_instance" {
  name        = "three-tier-app-instance-sg"
  description = "Allow traffic from App ALB and SSH from web instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from App ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app_alb.id]
  }

  ingress {
    description     = "SSH from Web Tier Instances"
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

# App Application Load Balancer
resource "aws_lb" "app" {
  name               = "three-tier-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_alb.id]
  subnets            = [for subnet in aws_subnet.app : subnet.id]

  tags = {
    Name = "three-tier-app-alb"
  }
}

# App ALB Target Group
resource "aws_lb_target_group" "app" {
  name        = "three-tier-app-tg"
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
    Name = "three-tier-app-tg"
  }
}

# App ALB Listener
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# App Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "three-tier-app-"
  image_id      = var.ami-id
  instance_type = "t2.micro"
  key_name      = var.key-pair-name

  vpc_security_group_ids = [aws_security_group.app_instance.id]

  user_data = filebase64("${path.module}/user-data.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-app-instance"
    }
  }
}

# App Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                = "three-tier-app-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  vpc_zone_identifier = [for subnet in aws_subnet.app : subnet.id]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  tag {
    key                 = "Name"
    value               = "three-tier-app-asg-instance"
    propagate_at_launch = true
  }
}
