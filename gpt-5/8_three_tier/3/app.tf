# -----------------------------
# app.tf
# -----------------------------
resource "aws_lb_target_group" "app" {
  name        = "three-tier-tg-app"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    path                = "/"
    matcher             = "200"
    protocol            = "HTTP"
    port                = "traffic-port"
  }

  tags = {
    Name = "three-tier-tg-app"
  }
}

# App ALB is internet-facing per requirement, but SG restricts to Web tier
resource "aws_lb" "app" {
  name               = "three-tier-alb-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_alb.id]
  # place in public subnets to be internet-facing; SG enforces least privilege
  subnets = [aws_subnet.web_az1.id, aws_subnet.web_az2.id]

  tags = {
    Name = "three-tier-alb-app"
  }
}

resource "aws_lb_listener" "app_http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "three-tier-lt-app-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.existing.key_name

  user_data = filebase64("${path.module}/user-data.sh")

  vpc_security_group_ids = [aws_security_group.app_instances.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "three-tier-app"
      Tier = "app"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "three-tier-app-volume"
    }
  }

  tags = {
    Name = "three-tier-lt-app"
  }
}

resource "aws_autoscaling_group" "app" {
  name                      = "three-tier-asg-app"
  min_size                  = var.asg_app_min
  desired_capacity          = var.asg_app_desired
  max_size                  = var.asg_app_max
  vpc_zone_identifier       = [aws_subnet.app_az1.id, aws_subnet.app_az2.id]
  health_check_type         = "EC2"
  health_check_grace_period = 90

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  tag {
    key                 = "Name"
    value               = "three-tier-asg-app"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb_listener.app_http]
}
