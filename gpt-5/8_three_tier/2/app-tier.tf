############################
# app-tier.tf
############################
# App ALB (internet-facing per requirements)
resource "aws_lb" "app" {
  name               = "${var.name_prefix}alb-app"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.sg_app_alb.id]
  subnets            = [aws_subnet.app_a.id, aws_subnet.app_b.id]

  tags = { Name = "${var.name_prefix}alb-app" }
}

resource "aws_lb_target_group" "app" {
  name        = "${var.name_prefix}tg-app"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }

  tags = { Name = "${var.name_prefix}tg-app" }
}

resource "aws_lb_listener" "app_http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# App Launch Template
resource "aws_launch_template" "app" {
  name_prefix            = "${var.name_prefix}lt-app-"
  image_id               = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.key_pair_name
  update_default_version = true
  user_data              = filebase64("user-data.sh")

  network_interfaces {
    security_groups             = [aws_security_group.sg_app_asg.id]
    associate_public_ip_address = false
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name_prefix}app-instance"
      Tier = "app"
    }
  }

  tags = { Name = "${var.name_prefix}lt-app" }
}

# App ASG
resource "aws_autoscaling_group" "app" {
  name                      = "${var.name_prefix}asg-app"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 1
  health_check_type         = "EC2"
  vpc_zone_identifier       = [aws_subnet.app_a.id, aws_subnet.app_b.id]
  force_delete              = true
  wait_for_capacity_timeout = "10m"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}asg-app"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "app" {
  autoscaling_group_name = aws_autoscaling_group.app.name
  lb_target_group_arn    = aws_lb_target_group.app.arn
}