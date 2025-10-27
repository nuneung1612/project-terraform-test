resource "aws_security_group" "web-alb-sg" {
  vpc_id = aws_vpc.main.id
  name   = "three-tier-web-alb-sg"

  tags = {
    Name = "three-tier-web-alb-sg"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web-instance-sg" {
  vpc_id = aws_vpc.main.id
  name   = "three-tier-web-instance-sg"

  tags = {
    Name = "three-tier-web-instance-sg"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-alb-sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "web-lt" {
  name          = "three-tier-web-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  name          = "three-tier-web-lt"

  tags = {
    Name = "three-tier-web-lt"
  }

  user_data = filebase64("${path.module}/user-data.sh")
}

resource "aws_autoscaling_group" "web-asg" {
  name                = "three-tier-web-asg"
  max_size            = var.max_asg_instances
  min_size            = var.min_asg_instances
  desired_capacity    = var.desired_asg_instances
  vpc_zone_identifier = [aws_subnet.web-a.id, aws_subnet.web-b.id]
  launch_template {
    id      = aws_launch_template.web-lt.id
    version = "$Latest"
  }

  tags = [
    {
      key                 = "Name"
      value               = "three-tier-web-asg"
      propagate_at_launch = true
    },
  ]
}

resource "aws_alb" "main" {
  name            = "three-tier-web-alb"
  subnets         = [aws_subnet.web-a.id, aws_subnet.web-b.id]
  security_groups = [aws_security_group.web-alb-sg.id]

  tags = {
    Name = "three-tier-web-alb"
  }
}

resource "aws_alb_target_group" "main" {
  name     = "three-tier-web-tg"
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
    Name = "three-tier-web-tg"
  }
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main.arn
    type             = "forward"
  }
}
