resource "aws_security_group" "three-tier-web-sg" {
  name        = "three-tier-web-sg"
  description = "Security group for web tier"
  vpc_id      = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-web-sg"
  }
}

resource "aws_security_group_rule" "three-tier-web-sg-allow-http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.three-tier-web-sg.id
  security_group_id        = aws_security_group.three-tier-web-sg.id
}

resource "aws_security_group_rule" "three-tier-web-sg-allow-ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.three-tier-web-sg.id
}

resource "aws_security_group_rule" "three-tier-web-sg-allow-outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.three-tier-web-sg.id
}

resource "aws_launch_template" "three-tier-web-lt" {
  name_prefix            = "three-tier-web-lt"
  image_id               = var.ami_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.three-tier-web-sg.id]
  user_data              = filebase64("${path.module}/user-data.sh")
  tags = {
    Name = "three-tier-web-lt"
  }
}

resource "aws_autoscaling_group" "three-tier-web-asg" {
  name                = "three-tier-web-asg"
  max_size            = 4
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.three-tier-web-subnet-1.id, aws_subnet.three-tier-web-subnet-2.id]
  launch_template {
    id      = aws_launch_template.three-tier-web-lt.id
    version = aws_launch_template.three-tier-web-lt.latest_version
  }
  depends_on = [aws_launch_template.three-tier-web-lt]
  tags = [
    {
      key                 = "Name"
      value               = "three-tier-web-asg"
      propagate_at_launch = true
    },
  ]
}

resource "aws_alb" "three-tier-web-alb" {
  name               = "three-tier-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.three-tier-web-sg.id]
  subnets            = [aws_subnet.three-tier-web-subnet-1.id, aws_subnet.three-tier-web-subnet-2.id]
  tags = {
    Name = "three-tier-web-alb"
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

resource "aws_alb_listener" "three-tier-web-lis" {
  load_balancer_arn = aws_alb.three-tier-web-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.three-tier-web-tg.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "three-tier-web-tg-attach" {
  target_group_arn = aws_alb_target_group.three-tier-web-tg.arn
  target_id        = aws_autoscaling_group.three-tier-web-asg.id
  port             = 80
}
