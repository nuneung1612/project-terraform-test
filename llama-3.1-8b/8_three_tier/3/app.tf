resource "aws_security_group" "three-tier-app-sg" {
  name        = "three-tier-app-sg"
  description = "Security group for app tier"
  vpc_id      = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-app-sg"
  }
}

resource "aws_security_group_rule" "three-tier-app-sg-allow-http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.three-tier-web-sg.id
  security_group_id        = aws_security_group.three-tier-app-sg.id
}

resource "aws_security_group_rule" "three-tier-app-sg-allow-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.three-tier-web-sg.id
  security_group_id        = aws_security_group.three-tier-app-sg.id
}

resource "aws_security_group_rule" "three-tier-app-sg-allow-outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.three-tier-app-sg.id
}

resource "aws_launch_template" "three-tier-app-lt" {
  name_prefix            = "three-tier-app-lt"
  image_id               = var.ami_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.three-tier-app-sg.id]
  user_data              = filebase64("${path.module}/user-data.sh")
  tags = {
    Name = "three-tier-app-lt"
  }
}

resource "aws_autoscaling_group" "three-tier-app-asg" {
  name                = "three-tier-app-asg"
  max_size            = 4
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.three-tier-app-subnet-1.id, aws_subnet.three-tier-app-subnet-2.id]
  launch_template {
    id      = aws_launch_template.three-tier-app-lt.id
    version = aws_launch_template.three-tier-app-lt.latest_version
  }
  depends_on = [aws_launch_template.three-tier-app-lt]
  tags = [
    {
      key                 = "Name"
      value               = "three-tier-app-asg"
      propagate_at_launch = true
    },
  ]
}

resource "aws_alb" "three-tier-app-alb" {
  name               = "three-tier-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.three-tier-app-sg.id]
  subnets            = [aws_subnet.three-tier-app-subnet-1.id, aws_subnet.three-tier-app-subnet-2.id]
  tags = {
    Name = "three-tier-app-alb"
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

resource "aws_alb_listener" "three-tier-app-lis" {
  load_balancer_arn = aws_alb.three-tier-app-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.three-tier-app-tg.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "three-tier-app-tg-attach" {
  target_group_arn = aws_alb_target_group.three-tier-app-tg.arn
  target_id        = aws_autoscaling_group.three-tier-app-asg.id
  port             = 80
}
