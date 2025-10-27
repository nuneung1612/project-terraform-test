resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "three-tier-alb-sg"
  }
}

resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group" "instance" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "three-tier-instance-sg"
  }
}

resource "aws_security_group_rule" "instance_alb_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.instance.id
}

resource "aws_security_group_rule" "instance_ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance.id
}

resource "aws_security_group_rule" "instance_alb_egress" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.instance.id
}

resource "aws_security_group" "app_alb" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "three-tier-app-alb-sg"
  }
}

resource "aws_security_group_rule" "app_alb_http_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.instance.id
  security_group_id        = aws_security_group.app_alb.id
}

resource "aws_launch_template" "web" {
  image_id           = var.ami_id
  instance_type      = "t2.micro"
  user_data          = base64encode(file("${path.module}/user-data.sh"))
  key_name           = var.key_pair_name
  security_group_ids = [aws_security_group.instance.id]
  tags = {
    Name = "three-tier-web-launch-template"
  }
}

resource "aws_launch_template" "app" {
  image_id           = var.ami_id
  instance_type      = "t2.micro"
  user_data          = base64encode(file("${path.module}/user-data.sh"))
  key_name           = var.key_pair_name
  security_group_ids = [aws_security_group.instance.id]
  tags = {
    Name = "three-tier-app-launch-template"
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "three-tier-web-asg"
  max_size            = 4
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.web_us-east-1a.id, aws_subnet.web_us-east-1b.id]
  launch_template {
    id      = aws_launch_template.web.id
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

resource "aws_autoscaling_group" "app" {
  name                = "three-tier-app-asg"
  max_size            = 4
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.app_us-east-1a.id, aws_subnet.app_us-east-1b.id]
  launch_template {
    id      = aws_launch_template.app.id
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

resource "aws_alb" "web" {
  name               = "three-tier-web-alb"
  subnets            = [aws_subnet.web_us-east-1a.id, aws_subnet.web_us-east-1b.id]
  security_groups    = [aws_security_group.alb.id]
  internal           = false
  load_balancer_type = "application"
  tags = {
    Name = "three-tier-web-alb"
  }
}

resource "aws_alb_target_group" "web" {
  name     = "three-tier-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  tags = {
    Name = "three-tier-web-tg"
  }
}

resource "aws_alb_listener" "web" {
  load_balancer_arn = aws_alb.web.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.web.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "web" {
  target_group_arn = aws_alb_target_group.web.arn
  target_id        = aws_autoscaling_group.web.id
  port             = 80
}

resource "aws_alb" "app" {
  name               = "three-tier-app-alb"
  subnets            = [aws_subnet.app_us-east-1a.id, aws_subnet.app_us-east-1b.id]
  security_groups    = [aws_security_group.app_alb.id]
  internal           = false
  load_balancer_type = "application"
  tags = {
    Name = "three-tier-app-alb"
  }
}

resource "aws_alb_target_group" "app" {
  name     = "three-tier-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
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

resource "aws_alb_target_group_attachment" "app" {
  target_group_arn = aws_alb_target_group.app.arn
  target_id        = aws_autoscaling_group.app.id
  port             = 80
}
