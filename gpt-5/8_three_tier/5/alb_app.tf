// alb_app.tf
resource "aws_lb" "app" {
  name               = "${local.name_prefix}alb-app"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.sg_app_alb.id]
  subnets            = [aws_subnet.app_a.id, aws_subnet.app_b.id]

  tags = merge(local.common_tags, { Name = "${local.name_prefix}alb-app" })
}

resource "aws_lb_target_group" "app" {
  name        = "${local.name_prefix}tg-app"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}tg-app" })
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
