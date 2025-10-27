resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = var.alb_type
  subnets            = [aws_subnet.public[0].id, aws_subnet.public[1].id]
  security_groups    = [aws_security_group.alb.id]
  tags = {
    Name = "main-alb"
  }
}

# Create target group
resource "aws_lb_target_group" "main" {
  name     = "main-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  tags = {
    Name = "main-tg"
  }
}

# Create listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.main.arn
    type             = "forward"
  }
}

# Attach EC2 instances to target group
resource "aws_lb_target_group_attachment" "web1" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

# Create ALB security group
resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "alb-sg"
  }

  # Allow all traffic from anywhere
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all egress traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
