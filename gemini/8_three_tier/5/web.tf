# --- ALB ---
resource "aws_lb" "web" {
  name               = "three-tier-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_alb.id]
  subnets            = aws_subnet.web[*].id

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-web-alb"
    }
  )
}

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

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-web-tg"
    }
  )
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# --- Auto Scaling ---
resource "aws_launch_template" "web" {
  name_prefix   = "three-tier-web-lt-"
  image_id      = var.ami-id
  instance_type = var.instance-type-web
  key_name      = var.key-pair-name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_instance.id]
  }

  user_data = filebase64("user-data.sh")

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-web-lt"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "three-tier-web-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  vpc_zone_identifier = aws_subnet.web[*].id

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]

  tag {
    key                 = "Name"
    value               = "three-tier-web-instance"
    propagate_at_launch = true
  }

  # Add other common tags
  tags = [for k, v in local.common_tags : { key = k, value = v, propagate_at_launch = true }]
}
