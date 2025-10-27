# --- ALB ---
resource "aws_lb" "app" {
  name               = "three-tier-app-alb"
  internal           = false # As per requirement, though 'true' is more typical for an app tier
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_alb.id]
  subnets            = aws_subnet.app[*].id

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-app-alb"
    }
  )
}

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

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-app-tg"
    }
  )
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# --- Auto Scaling ---
resource "aws_launch_template" "app" {
  name_prefix   = "three-tier-app-lt-"
  image_id      = var.ami-id
  instance_type = var.instance-type-app
  key_name      = var.key-pair-name

  network_interfaces {
    security_groups = [aws_security_group.app_instance.id]
  }

  user_data = filebase64("user-data.sh")

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-app-lt"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "three-tier-app-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  vpc_zone_identifier = aws_subnet.app[*].id

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  tag {
    key                 = "Name"
    value               = "three-tier-app-instance"
    propagate_at_launch = true
  }

  # Add other common tags
  tags = [for k, v in local.common_tags : { key = k, value = v, propagate_at_launch = true }]
}
