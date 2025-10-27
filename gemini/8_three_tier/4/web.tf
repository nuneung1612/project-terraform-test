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

resource "aws_lb_target_group" "web" {
  name     = "three-tier-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.three_tier.id
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

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "three-tier-web-"
  image_id      = var.ami-id
  instance_type = var.instance-type
  key_name      = var.key-name

  network_interfaces {
    security_groups = [aws_security_group.web_instance.id]
  }

  user_data = filebase64("${path.module}/user-data.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-web-instance"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "three-tier-web-asg"
  min_size            = 1
  desired_capacity    = 2
  max_size            = 4
  vpc_zone_identifier = [for subnet in aws_subnet.web : subnet.id]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]
  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "three-tier-web-asg-instance"
    propagate_at_launch = true
  }
}
