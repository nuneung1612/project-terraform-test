# Create ALB security group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "ALB security group"
  vpc_id      = aws_vpc.vpc_project.id

  # Allow all inbound and outbound traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ALB
resource "aws_alb" "alb" {
  name            = "alb"
  subnets         = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  security_groups = [aws_security_group.alb_sg.id]
}

# Create target group
resource "aws_alb_target_group" "project_tg" {
  name     = "project-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_project.id
}

# Create target group attachment
resource "aws_alb_target_group_attachment" "project_tg_attach_1" {
  target_group_arn = aws_alb_target_group.project_tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_alb_target_group_attachment" "project_tg_attach_2" {
  target_group_arn = aws_alb_target_group.project_tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

# Create HTTP listener
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.project_tg.arn
    type             = "forward"
  }
}
