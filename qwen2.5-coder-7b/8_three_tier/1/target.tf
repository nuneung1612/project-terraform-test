resource "aws_lb_target_group" "web" {
  name     = "three-tier-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                      = "/"
    interval_seconds          = 30
    timeout_seconds           = 5
    healthy_threshold_count   = 5
    unhealthy_threshold_count = 2
    matcher                   = "200"
  }

  tag {
    key                 = "Name"
    value               = "three-tier-web-tg"
    propagate_at_launch = true
  }
}

resource "aws_lb_target_group" "app" {
  name     = "three-tier-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                      = "/"
    interval_seconds          = 30
    timeout_seconds           = 5
    healthy_threshold_count   = 5
    unhealthy_threshold_count = 2
    matcher                   = "200"
  }

  tag {
    key                 = "Name"
    value               = "three-tier-app-tg"
    propagate_at_launch = true
  }
}
