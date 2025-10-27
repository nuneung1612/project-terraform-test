# Security Groups
resource "aws_security_group" "three-tier-app-sg" {
  name        = "three-tier-app-sg"
  description = "Security Group for App Tier"
  vpc_id      = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-app-sg"
  }
}

resource "aws_security_group_rule" "three-tier-app-sg-http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.three-tier-app-sg.id
  source_security_group_id = aws_security_group.three-tier-web-sg.id
}

resource "aws_security_group_rule" "three-tier-app-sg-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.three-tier-app-sg.id
  source_security_group_id = aws_security_group.three-tier-web-sg.id
}

# Load Balancer
resource "aws_alb" "three-tier-alb-app" {
  name            = "three-tier-alb-app"
  subnets         = [aws_subnet.three-tier-app-subnet-1.id, aws_subnet.three-tier-app-subnet-2.id]
  security_groups = [aws_security_group.three-tier-app-sg.id]
  internal        = false
  idle_timeout    = 60
  tags = {
    Name = "three-tier-alb-app"
  }
}

resource "aws_alb_target_group" "three-tier-app-tg" {
  name     = "three-tier-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-app-tg"
  }
}

resource "aws_alb_listener" "three-tier-alb-app-lis" {
  load_balancer_arn = aws_alb.three-tier-alb-app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.three-tier-app-tg.arn
    type             = "forward"
  }
}

# Auto Scaling Group
resource "aws_launch_template" "three-tier-app-lt" {
  name_prefix   = "three-tier-app-lt-"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  user_data     = base64encode(file("user-data.sh"))

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.three-tier-app-sg.id]
  }

  tag {
    key   = "Name"
    value = "three-tier-app-lt"
  }
}

resource "aws_autoscaling_group" "three-tier-app-asg" {
  name                = "three-tier-app-asg"
  max_size            = 4
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.three-tier-app-subnet-1.id, aws_subnet.three-tier-app-subnet-2.id]
  launch_template {
    name    = aws_launch_template.three-tier-app-lt.name
    version = aws_launch_template.three-tier-app-lt.latest_version
  }

  tag {
    key                 = "Name"
    value               = "three-tier-app-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "three-tier-app-asg-attachment" {
  autoscaling_group_name = aws_autoscaling_group.three-tier-app-asg.id
  alb_target_group_arn   = aws_alb_target_group.three-tier-app-tg.arn
  depends_on             = [aws_alb_listener.three-tier-alb-app-lis]
}
