// compute_web.tf
resource "aws_launch_template" "web" {
  name_prefix   = "${local.name_prefix}lt-web-"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_pair_name
  user_data     = filebase64(var.user_data_file)

  network_interfaces {
    security_groups = [aws_security_group.sg_web_instances.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}web-instance"
      Tier = "web"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}web-volume"
      Tier = "web"
    })
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}lt-web" })
}

resource "aws_autoscaling_group" "web" {
  name                = "${local.name_prefix}asg-web"
  desired_capacity    = var.asg_sizes.desired
  max_size            = var.asg_sizes.max
  min_size            = var.asg_sizes.min
  health_check_type   = "EC2"
  vpc_zone_identifier = [aws_subnet.web_a.id, aws_subnet.web_b.id]
  target_group_arns   = [aws_lb_target_group.web.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}asg-web"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb_listener.web_http]
}
