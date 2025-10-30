resource "aws_alb" "alb" {
  name            = "alb"
  subnets         = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  security_groups = [aws_security_group.alb-sg.id]
  depends_on      = [aws_vpc.vpc-project]
}

resource "aws_alb_target_group" "project-tg" {
  name        = "project-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc-project.id
  target_type = "instance"
}

resource "aws_alb_target_group_attachment" "web1-attachment" {
  target_group_arn = aws_alb_target_group.project-tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
  depends_on       = [aws_instance.web1]
}

resource "aws_alb_target_group_attachment" "web2-attachment" {
  target_group_arn = aws_alb_target_group.project-tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
  depends_on       = [aws_instance.web2]
}

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.project-tg.arn
    type             = "forward"
  }
}

