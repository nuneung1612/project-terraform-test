resource "aws_lb" "web" {
  name               = "three-tier-web-lb"
  internal           = false
  security_groups    = [aws_security_group.alb_web.id]
  subnets            = aws_subnet.web[*].id
  idle_timeout_minutes = 60

  listener {
    port     = 80
    protocol = "HTTP"

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.web.arn
    }
  }

  tags = {
    Name = "three-tier-web-lb"
  }
}

resource "aws_lb" "app" {
  name               = "three-tier-app-lb"
  internal           = false
  security_groups    = [aws_security_group.alb_app.id]
  subnets            = aws_subnet.app[*].id
  idle_timeout_minutes = 60

  listener {
    port     = 80
    protocol = "HTTP"

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.app.arn
    }
  }

  tags = {
    Name = "three-tier-app-lb"
  }
}
