resource "aws_security_group" "app-alb-sg" {
  vpc_id = aws_vpc.main.id
  name   = "three-tier-app-alb-sg"

  tags = {
    Name = "three-tier-app-alb-sg"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.web-alb-sg.id]
  }
}

resource "aws_security_group" "app-instance-sg" {
  vpc_id = aws_vpc.main.id
  name   = "three-tier-app-instance-sg"

  tags = {
    Name = "three-tier-app-instance-sg"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app-alb-sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = [aws_security_group.web-alb-sg.id]
  }
}

resource "aws_launch_template" "app-lt" {
  name          = "three-tier-app-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  name          = "three-tier-app-lt"

  tags = {
    Name = "three-tier-app-lt"
  }

  user_data = filebase64("${path.module}/user-data.sh")
}

resource "aws_autoscaling_group" "app-asg" {
  name                = "three-tier-app-asg"
  max_size            = var.max_asg_instances
  min_size            = var.min_asg_instances
  desired_capacity    = var.desired_asg_instances
  vpc_zone_identifier = [aws_subnet.app-a.id, aws_subnet.app-b.id]
  launch_template {
    id      = aws_launch_template.app-lt.id
    version = "$Latest"
  }

  tags = [
    {
      key                 = "Name"
      value               = "three-tier-app-asg"
      propagate_at_launch = true
    },
  ]
}

resource "aws_alb" "app" {
  name            = "three-tier-app-alb"
  subnets         = [aws_subnet.app-a.id, aws_subnet.app-b.id]
  security_groups = [aws_security_group.app-alb-sg.id]

  tags = {
    Name = "three-tier-app-alb"
  }
}

resource "aws_alb_target_group" "app" {
  name     = "three-tier-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "three-tier-app-tg"
  }
}

resource "aws_alb_listener" "app" {
  load_balancer_arn = aws_alb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.arn
    type             = "forward"
  }
}
