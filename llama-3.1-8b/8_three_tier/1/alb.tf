resource "aws_alb" "three-tier-web-alb" {
  name            = "three-tier-web-alb"
  subnets         = [aws_subnet.three-tier-web-subnet-1a.id, aws_subnet.three-tier-web-subnet-1b.id]
  security_groups = [aws_security_group.three-tier-alb-sg.id]

  tags = {
    Name = "three-tier-web-alb"
  }
}

resource "aws_alb_target_group" "three-tier-web-tg" {
  name     = "three-tier-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.three-tier-vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_alb_listener" "three-tier-web-alb-listener" {
  load_balancer_arn = aws_alb.three-tier-web-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.three-tier-web-tg.arn
    type             = "forward"
  }
}
