# Security Groups
resource "aws_security_group" "three-tier-web-sg" {
  name        = "three-tier-web-sg"
  description = "Security Group for Web Tier"
  vpc_id      = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-web-sg"
  }
}

resource "aws_security_group_rule" "three-tier-web-sg-http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.three-tier-web-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "three-tier-web-sg-ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.three-tier-web-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Load Balancer
resource "aws_alb" "three-tier-alb" {
  name               = "three-tier-alb"
  subnets            = [aws_subnet.three-tier-web-subnet-1.id, aws_subnet.three-tier-web-subnet-2.id]
  security_groups    = [aws_security_group.three-tier-web-sg.id]
  internal           = false
  idle_timeout       = 60
  tags = {
    Name = "three-tier-alb"
  }
}

resource "aws_alb_target_group" "three-tier-web-tg" {
  name     = "three-tier-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-web-tg"
  }
}

resource "aws_alb_listener" "three-tier-alb-lis" {
  load_balancer_arn = aws_alb.three-tier-alb.arn
  port               = "80"
  protocol           = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.three-tier-web-tg.arn
    type             = "forward"
  }
}

# Auto Scaling Group
resource "aws_launch_template" "three-tier-web-lt" {
  name_prefix = "three-tier-web-lt-"
  image_id    = var.ami_id
  instance_type = "t2.micro"
  user_data = base64encode(file("user-data.sh"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.three-tier-web-sg.id]
  }

  tag {
    key   = "Name"
    value = "three-tier-web-lt"
  }
}

resource "aws_autoscaling_group" "three-tier-web-asg" {
  name                = "three-tier-web-asg"
  max_size            = 4
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.three-tier-web-subnet-1.id, aws_subnet.three-tier-web-subnet-2.id]
  launch_template {
    name    = aws_launch_template.three-tier-web-lt.name
    version = aws_launch_template.three-tier-web-lt.latest_version
  }

  tag {
    key                 = "Name"
    value               = "three-tier-web-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "three-tier-web-asg-attachment" {
  autoscaling_group_name = aws_autoscaling_group.three-tier-web-asg.id
  alb_target_group_arn   = aws_alb_target_group.three-tier-web-tg.arn
  depends_on             = [aws_alb_listener.three-tier-alb-lis]
}
