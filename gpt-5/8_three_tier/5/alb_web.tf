// alb_web.tf
resource "aws_lb" "web" {
  name               = "${local.name_prefix}alb-web"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.sg_web_alb.id]
  subnets            = [aws_subnet.web_a.id, aws_subnet.web_b.id]

  tags = merge(local.common_tags, { Name = "${local.name_prefix}alb-web" })
}

resource "aws_lb_target_group" "web" {
  name        = "${local.name_prefix}tg-web"
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

  tags = merge(local.common_tags, { Name = "${local.name_prefix}tg-web" })
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
