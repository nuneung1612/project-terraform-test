resource "aws_lb" "app" {
  name               = "app-alb"
  internal           = false
  security_groups    = [aws_security_group.alb.name]
  load_balancer_type = "application"

  subnets = aws_subnet.public[*].id

  tags = {
    Name = "app-alb"
  }
}

resource "aws_target_group" "web" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    path                = "/"
    matcher             = "200-299"
  }

  tags = {
    Name = "web-target-group"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_target_group.web.arn
  }
}

resource "aws_lb_target_group_attachment" "web" {
  count          = 2
  target_group_arn = aws_target_group.web.arn
  target_id      = aws_instance.web[count.index].id
}
