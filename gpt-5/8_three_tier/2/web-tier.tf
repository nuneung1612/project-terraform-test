############################
# web-tier.tf
############################
# Web ALB
resource "aws_lb" "web" {
  name               = "${var.name_prefix}alb-web"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.sg_web_alb.id]
  subnets            = [aws_subnet.web_a.id, aws_subnet.web_b.id]

  tags = { Name = "${var.name_prefix}alb-web" }
}

resource "aws_lb_target_group" "web" {
  name        = "${var.name_prefix}tg-web"
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

  tags = { Name = "${var.name_prefix}tg-web" }
}

resource "aws_lb_listener" "web_http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Web Launch Template
resource "aws_launch_template" "web" {
  name_prefix            = "${var.name_prefix}lt-web-"
  image_id               = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.key_pair_name
  update_default_version = true
  user_data              = filebase64("user-data.sh")

  network_interfaces {
    security_groups             = [aws_security_group.sg_web_asg.id]
    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name_prefix}web-instance"
      Tier = "web"
    }
  }

  tags = { Name = "${var.name_prefix}lt-web" }
}

# Web ASG
resource "aws_autoscaling_group" "web" {
  name                      = "${var.name_prefix}asg-web"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 1
  health_check_type         = "EC2"
  vpc_zone_identifier       = [aws_subnet.web_a.id, aws_subnet.web_b.id]
  force_delete              = true
  wait_for_capacity_timeout = "10m"

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}asg-web"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "web" {
  autoscaling_group_name = aws_autoscaling_group.web.name
  lb_target_group_arn    = aws_lb_target_group.web.arn
}