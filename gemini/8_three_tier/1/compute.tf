# Web Tier Resources
resource "aws_launch_template" "web" {
  name_prefix   = "three-tier-web-"
  image_id      = var.ami-id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.three_tier_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.web_instance.id]

  user_data = filebase64("${path.module}/user-data.sh")

  tags = {
    Name = "three-tier-web-lt"
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "three-tier-web-asg"
  vpc_zone_identifier = [aws_subnet.web_a.id, aws_subnet.web_b.id]
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]
}

resource "aws_lb" "web" {
  name               = "three-tier-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_alb.id]
  subnets            = [aws_subnet.web_a.id, aws_subnet.web_b.id]

  tags = {
    Name = "three-tier-web-alb"
  }
}

resource "aws_lb_target_group" "web" {
  name        = "three-tier-web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# App Tier Resources
resource "aws_launch_template" "app" {
  name_prefix   = "three-tier-app-"
  image_id      = var.ami-id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.three_tier_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.app_instance.id]

  tags = {
    Name = "three-tier-app-lt"
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "three-tier-app-asg"
  vpc_zone_identifier = [aws_subnet.app_a.id, aws_subnet.app_b.id]
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]
}

resource "aws_lb" "app" {
  name               = "three-tier-app-alb"
  internal           = true # Changed to true as it is internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_alb.id]
  subnets            = [aws_subnet.app_a.id, aws_subnet.app_b.id]

  tags = {
    Name = "three-tier-app-alb"
  }
}

resource "aws_lb_target_group" "app" {
  name        = "three-tier-app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
