# ===================================================================
# compute.tf (Web & App tiers)
# ===================================================================

# --- Web Tier ---

resource "aws_lb" "web" {
  name               = "${local.project_prefix}-alb-web"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.web_a.id, aws_subnet.web_b.id]
  security_groups    = [aws_security_group.alb_web.id]

  tags = {
    Name = "${local.project_prefix}-alb-web"
    Tier = "web"
  }
}

resource "aws_lb_target_group" "web" {
  name        = "${local.project_prefix}-tg-web"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }

  tags = {
    Name = "${local.project_prefix}-tg-web"
    Tier = "web"
  }
}

resource "aws_lb_listener" "web_http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "${local.project_prefix}-lt-web-"
  image_id      = var.config["ami-id"]
  instance_type = "t2.micro"
  key_name      = var.config["key-pair-name"]

  vpc_security_group_ids = [aws_security_group.web_instances.id]

  user_data = filebase64("user-data.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.project_prefix}-web"
      Tier = "web"
    }
  }

  tags = {
    Name = "${local.project_prefix}-lt-web"
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "${local.project_prefix}-asg-web"
  min_size                  = 1
  desired_capacity          = 2
  max_size                  = 4
  vpc_zone_identifier       = [aws_subnet.web_a.id, aws_subnet.web_b.id]
  health_check_type         = "EC2"
  health_check_grace_period = 90

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]

  tag {
    key                 = "Name"
    value               = "${local.project_prefix}-web"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb_listener.web_http]
}

# --- Application Tier ---

resource "aws_lb" "app" {
  name               = "${local.project_prefix}-alb-app"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.web_a.id, aws_subnet.web_b.id] # internet-facing in public subnets
  security_groups    = [aws_security_group.alb_app.id]

  tags = {
    Name = "${local.project_prefix}-alb-app"
    Tier = "app"
  }
}

resource "aws_lb_target_group" "app" {
  name        = "${local.project_prefix}-tg-app"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }

  tags = {
    Name = "${local.project_prefix}-tg-app"
    Tier = "app"
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
  name_prefix   = "${local.project_prefix}-lt-app-"
  image_id      = var.config["ami-id"]
  instance_type = "t2.micro"
  key_name      = var.config["key-pair-name"]

  vpc_security_group_ids = [aws_security_group.app_instances.id]

  user_data = filebase64("user-data.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.project_prefix}-app"
      Tier = "app"
    }
  }

  tags = {
    Name = "${local.project_prefix}-lt-app"
  }
}

resource "aws_autoscaling_group" "app" {
  name                      = "${local.project_prefix}-asg-app"
  min_size                  = 1
  desired_capacity          = 2
  max_size                  = 4
  vpc_zone_identifier       = [aws_subnet.app_a.id, aws_subnet.app_b.id]
  health_check_type         = "EC2"
  health_check_grace_period = 90

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  tag {
    key                 = "Name"
    value               = "${local.project_prefix}-app"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb_listener.app_http]
}
