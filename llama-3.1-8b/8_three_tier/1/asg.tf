resource "aws_launch_template" "three-tier-web-launch-template" {
  name = "three-tier-web-launch-template"

  image_id        = var.ami-id
  instance_type   = "t2.micro"
  key_name        = var.key-pair-name
  user_data       = filebase64("${path.module}/user-data.sh")
  vpc_security_group_ids = [aws_security_group.three-tier-web-asg-sg.id]

  tags = {
    Name = "three-tier-web-launch-template"
  }
}

resource "aws_autoscaling_group" "three-tier-web-asg" {
  name                      = "three-tier-web-asg"
  max_size                  = 4
  min_size                  = 1
  desired_capacity          = 2
  health_check_type         = "ELB"
  launch_configuration      = aws_launch_template.three-tier-web-launch-template.name
  vpc_zone_identifier       = [aws_subnet.three-tier-web-subnet-1a.id, aws_subnet.three-tier-web-subnet-1b.id]
  target_group_arns         = [aws_alb_target_group.three-tier-web-tg.arn]
  termination_policies      = ["OldestInstance"]
  tag {
    key                 = "Name"
    value               = "three-tier-web-asg"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "three-tier-app-launch-template" {
  name = "three-tier-app-launch-template"

  image_id        = var.ami-id
  instance_type   = "t2.micro"
  key_name        = var.key-pair-name
  user_data       = filebase64("${path.module}/user-data.sh")
  vpc_security_group_ids = [aws_security_group.three-tier-app-asg-sg.id]

  tags = {
    Name = "three-tier-app-launch-template"
  }
}

resource "aws_autoscaling_group" "three-tier-app-asg" {
  name                      = "three-tier-app-asg"
  max_size                  = 4
  min_size                  = 1
  desired_capacity          = 2
  health_check_type         = "ELB"
  launch_configuration      = aws_launch_template.three-tier-app-launch-template.name
  vpc_zone_identifier       = [aws_subnet.three-tier-app-subnet-1a.id, aws_subnet.three-tier-app-subnet-1b.id]
  target_group_arns         = [aws_alb_target_group.three-tier-web-tg.arn]
  termination_policies      = ["OldestInstance"]
  tag {
    key                 = "Name"
    value               = "three-tier-app-asg"
    propagate_at_launch = true
  }
}
