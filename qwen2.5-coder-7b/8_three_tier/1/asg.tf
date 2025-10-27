resource "aws_autoscaling_group" "web" {
  launch_template {
    id      = aws_launch_template.web.latest_version_number
    version = aws_launch_template.web.latest_version_number
  }
  min_size            = 1
  desired_capacity    = 2
  max_size            = 4
  vpc_zone_identifier = aws_subnet.web[*].id
  load_balancers      = [aws_lb.web.dns_name]
  health_check_type   = "EC2"
  target_group_arns   = [aws_lb_target_group.web.arn]

  tag {
    key                 = "Name"
    value               = "three-tier-web-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "app" {
  launch_template {
    id      = aws_launch_template.app.latest_version_number
    version = aws_launch_template.app.latest_version_number
  }
  min_size            = 1
  desired_capacity    = 2
  max_size            = 4
  vpc_zone_identifier = aws_subnet.app[*].id
  load_balancers      = [aws_lb.app.dns_name]
  health_check_type   = "EC2"
  target_group_arns   = [aws_lb_target_group.app.arn]

  tag {
    key                 = "Name"
    value               = "three-tier-app-asg"
    propagate_at_launch = true
  }
}
