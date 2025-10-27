# compute-app.tf
resource "aws_launch_template" "three-tier-app-lt" {
  name          = "three-tier-app-lt"
  image_id      = var.ami-id
  instance_type = var.instance-type
  key_name      = var.key-pair-name

  user_data = filebase64("user-data.sh")

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.three-tier-app-instance-sg.id]
  }

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

resource "aws_lb_listener" "three-tier-app-listener" {
  load_balancer_arn = aws_lb.three-tier-app-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.three-tier-app-tg.arn
  }
}

resource "aws_autoscaling_group" "three-tier-app-asg" {
  name                = "three-tier-app-asg"
  min_size            = 1
  desired_capacity    = 2
  max_size            = 4
  vpc_zone_identifier = aws_subnet.three-tier-app-subnet[*].id
  target_group_arns   = [aws_lb_target_group.three-tier-app-tg.arn]
  health_check_type   = "EC2"

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