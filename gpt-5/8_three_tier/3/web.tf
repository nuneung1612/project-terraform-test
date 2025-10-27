# -----------------------------
# web.tf
# -----------------------------
resource "aws_lb_target_group" "web" {
  name        = "three-tier-tg-web"
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
    Name = "three-tier-tg-web"
  }
}

resource "aws_lb" "web" {
  name               = "three-tier-alb-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_alb.id]
  subnets            = [aws_subnet.web_az1.id, aws_subnet.web_az2.id]

  tags = {
    Name = "three-tier-alb-web"
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
  name_prefix   = "three-tier-lt-web-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.existing.key_name

  user_data = filebase64("${path.module}/user-data.sh")

  vpc_security_group_ids = [aws_security_group.web_instances.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "three-tier-web"
      Tier = "web"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "three-tier-web-volume"
    }
  }

  tags = {
    Name = "three-tier-lt-web"
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "three-tier-asg-web"
  min_size                  = var.asg_web_min
  desired_capacity          = var.asg_web_desired
  max_size                  = var.asg_web_max
  vpc_zone_identifier       = [aws_subnet.web_az1.id, aws_subnet.web_az2.id]
  health_check_type         = "EC2"
  health_check_grace_period = 90

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]

  tag {
    key                 = "Name"
    value               = "three-tier-asg-web"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb_listener.web_http]
}

