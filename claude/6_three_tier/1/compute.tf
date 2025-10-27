# Web Tier Application Load Balancer
resource "aws_lb" "three-tier-web-alb" {
  name               = "three-tier-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.three-tier-web-alb-sg.id]
  subnets            = aws_subnet.three-tier-web-subnet[*].id

  tags = {
    Name = "three-tier-web-alb"
  }
}

# Web Tier Target Group
resource "aws_lb_target_group" "three-tier-web-tg" {
  name     = "three-tier-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.three-tier-vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "three-tier-web-tg"
  }
}

# Web Tier ALB Listener
resource "aws_lb_listener" "three-tier-web-listener" {
  load_balancer_arn = aws_lb.three-tier-web-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.three-tier-web-tg.arn
  }
}

# Web Tier Launch Template
resource "aws_launch_template" "three-tier-web-lt" {
  name          = "three-tier-web-lt"
  image_id      = var.ami-id
  instance_type = var.instance-type
  key_name      = var.key-pair-name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.three-tier-web-instance-sg.id]
  }

  user_data = filebase64("${path.module}/user-data-web.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-web-instance"
    }
  }

  tags = {
    Name = "three-tier-web-lt"
  }
}

# Web Tier Auto Scaling Group
resource "aws_autoscaling_group" "three-tier-web-asg" {
  name                = "three-tier-web-asg"
  vpc_zone_identifier = aws_subnet.three-tier-web-subnet[*].id
  target_group_arns   = [aws_lb_target_group.three-tier-web-tg.arn]
  health_check_type   = "EC2"
  health_check_grace_period = 300
  min_size            = var.web-asg-min-size
  desired_capacity    = var.web-asg-desired-capacity
  max_size            = var.web-asg-max-size

  launch_template {
    id      = aws_launch_template.three-tier-web-lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "three-tier-web-asg"
    propagate_at_launch = false
  }
}

# App Tier Application Load Balancer
resource "aws_lb" "three-tier-app-alb" {
  name               = "three-tier-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.three-tier-app-alb-sg.id]
  subnets            = aws_subnet.three-tier-web-subnet[*].id

  tags = {
    Name = "three-tier-app-alb"
  }
}

# App Tier Target Group
resource "aws_lb_target_group" "three-tier-app-tg" {
  name     = "three-tier-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.three-tier-vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "three-tier-app-tg"
  }
}

# App Tier ALB Listener
resource "aws_lb_listener" "three-tier-app-listener" {
  load_balancer_arn = aws_lb.three-tier-app-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.three-tier-app-tg.arn
  }
}

# App Tier Launch Template
resource "aws_launch_template" "three-tier-app-lt" {
  name          = "three-tier-app-lt"
  image_id      = var.ami-id
  instance_type = var.instance-type
  key_name      = var.key-pair-name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.three-tier-app-instance-sg.id]
  }

  user_data = filebase64("${path.module}/user-data-app.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-app-instance"
    }
  }

  tags = {
    Name = "three-tier-app-lt"
  }
}

# App Tier Auto Scaling Group
resource "aws_autoscaling_group" "three-tier-app-asg" {
  name                = "three-tier-app-asg"
  vpc_zone_identifier = aws_subnet.three-tier-app-subnet[*].id
  target_group_arns   = [aws_lb_target_group.three-tier-app-tg.arn]
  health_check_type   = "EC2"
  health_check_grace_period = 300
  min_size            = var.app-asg-min-size
  desired_capacity    = var.app-asg-desired-capacity
  max_size            = var.app-asg-max-size

  launch_template {
    id      = aws_launch_template.three-tier-app-lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "three-tier-app-asg"
    propagate_at_launch = false
  }
}