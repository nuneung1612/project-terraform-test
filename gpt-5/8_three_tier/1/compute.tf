# compute.tf
################################
# Security Groups
################################

# Web ALB SG: allow HTTP from internet
resource "aws_security_group" "three_tier_web_alb_sg" {
  name        = "three-tier-sg-web-alb"
  description = "three-tier web ALB security group"
  vpc_id      = aws_vpc.three_tier.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "three-tier-sg-web-alb" }
}

# Web Instance SG: HTTP from Web ALB SG, SSH from anywhere
resource "aws_security_group" "three_tier_web_instance_sg" {
  name        = "three-tier-sg-web-instance"
  description = "three-tier web instance SG"
  vpc_id      = aws_vpc.three_tier.id

  ingress {
    description     = "HTTP from Web ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_web_alb_sg.id]
  }

  ingress {
    description = "SSH from internet (demo)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "three-tier-sg-web-instance" }
}

# App ALB SG: HTTP from Web Instance SG
resource "aws_security_group" "three_tier_app_alb_sg" {
  name        = "three-tier-sg-app-alb"
  description = "three-tier app ALB SG"
  vpc_id      = aws_vpc.three_tier.id

  ingress {
    description     = "HTTP from Web Instances"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_web_instance_sg.id]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "three-tier-sg-app-alb" }
}

# App Instance SG: HTTP from App ALB, SSH from Web Instance SG
resource "aws_security_group" "three_tier_app_instance_sg" {
  name        = "three-tier-sg-app-instance"
  description = "three-tier app instance SG"
  vpc_id      = aws_vpc.three_tier.id

  ingress {
    description     = "HTTP from App ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_app_alb_sg.id]
  }

  ingress {
    description     = "SSH from Web Instances"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_web_instance_sg.id]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "three-tier-sg-app-instance" }
}

################################
# Web Tier - ALB + LT + ASG
################################
resource "aws_lb" "three_tier_web_alb" {
  name               = "three-tier-alb-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.three_tier_web_alb_sg.id]
  subnets            = [for s in aws_subnet.three_tier_web : s.id]

  tags = { Name = "three-tier-alb-web" }
}

resource "aws_lb_target_group" "three_tier_web_tg" {
  name        = "three-tier-tg-web"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.three_tier.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = { Name = "three-tier-tg-web" }
}

resource "aws_lb_listener" "three_tier_web_http" {
  load_balancer_arn = aws_lb.three_tier_web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.three_tier_web_tg.arn
  }
}

# Use filebase64() for web user-data as required
resource "aws_launch_template" "three_tier_web_lt" {
  name_prefix               = "three-tier-lt-web-"
  image_id                  = var.ami_id
  instance_type             = var.web_instance_type
  key_name                  = var.key_pair_name
  vpc_security_group_ids    = [aws_security_group.three_tier_web_instance_sg.id]
  user_data                 = filebase64("${path.root}/user-data.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-web"
      Tier = "web"
    }
  }

  tags = { Name = "three-tier-lt-web" }
}

resource "aws_autoscaling_group" "three_tier_web_asg" {
  name                      = "three-tier-asg-web"
  max_size                  = 4
  min_size                  = 1
  desired_capacity          = 2
  vpc_zone_identifier       = [for s in aws_subnet.three_tier_web : s.id]
  health_check_type         = "EC2"
  health_check_grace_period = 90
  target_group_arns         = [aws_lb_target_group.three_tier_web_tg.arn]

  launch_template {
    id      = aws_launch_template.three_tier_web_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "three-tier-asg-web"
    propagate_at_launch = true
  }

  depends_on = [aws_lb_listener.three_tier_web_http]
}

################################
# App Tier - ALB + LT + ASG
################################
# Per requirement: internet-facing ALB for app tier as well
resource "aws_lb" "three_tier_app_alb" {
  name               = "three-tier-alb-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.three_tier_app_alb_sg.id]
  # Internet-facing ALB must be in public subnets
  subnets = [for s in aws_subnet.three_tier_web : s.id]

  tags = { Name = "three-tier-alb-app" }
}

resource "aws_lb_target_group" "three_tier_app_tg" {
  name        = "three-tier-tg-app"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.three_tier.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = { Name = "three-tier-tg-app" }
}

resource "aws_lb_listener" "three_tier_app_http" {
  load_balancer_arn = aws_lb.three_tier_app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.three_tier_app_tg.arn
  }
}

resource "aws_launch_template" "three_tier_app_lt" {
  name_prefix            = "three-tier-lt-app-"
  image_id               = var.ami_id
  instance_type          = var.app_instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.three_tier_app_instance_sg.id]
  user_data              = base64encode(<<-EOF
    #!/bin/bash
    yum -y update
    yum -y install httpd
    systemctl enable --now httpd
    echo "<h1>three-tier - App Tier</h1>" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-app"
      Tier = "app"
    }
  }

  tags = { Name = "three-tier-lt-app" }
}

resource "aws_autoscaling_group" "three_tier_app_asg" {
  name                      = "three-tier-asg-app"
  max_size                  = 4
  min_size                  = 1
  desired_capacity          = 2
  vpc_zone_identifier       = [for s in aws_subnet.three_tier_app : s.id]
  health_check_type         = "EC2"
  health_check_grace_period = 90
  target_group_arns         = [aws_lb_target_group.three_tier_app_tg.arn]

  launch_template {
    id      = aws_launch_template.three_tier_app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "three-tier-asg-app"
    propagate_at_launch = true
  }

  depends_on = [aws_lb_listener.three_tier_app_http]
}

output "web_alb_dns_name" {
  value = aws_lb.three_tier_web_alb.dns_name
}

output "app_alb_dns_name" {
  value = aws_lb.three_tier_app_alb.dns_name
}
