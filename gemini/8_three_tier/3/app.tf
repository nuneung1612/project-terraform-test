# --- Security Groups ---
resource "aws_security_group" "app-alb-sg" {
  name        = "three-tier-app-alb-sg"
  description = "Allow HTTP inbound traffic from web tier"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    description     = "HTTP from Web Tier Instances"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-instance-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-app-alb-sg"
  }
}

resource "aws_security_group" "app-instance-sg" {
  name        = "three-tier-app-instance-sg"
  description = "Allow HTTP from App ALB and SSH from web tier"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    description     = "HTTP from App ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app-alb-sg.id]
  }

  ingress {
    description     = "SSH from Web Tier Instances"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web-instance-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-app-instance-sg"
  }
}

# --- Application Load Balancer ---
resource "aws_lb" "app-alb" {
  name               = "three-tier-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app-alb-sg.id]
  subnets            = [aws_subnet.app-subnet-a.id, aws_subnet.app-subnet-b.id]

  tags = {
    Name = "three-tier-app-alb"
  }
}

resource "aws_lb_target_group" "app-tg" {
  name        = "three-tier-app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.three-tier-vpc.id
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

  tags = {
    Name = "three-tier-app-tg"
  }
}

resource "aws_lb_listener" "app-listener" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-tg.arn
  }
}

# --- Auto Scaling ---
resource "aws_launch_template" "app-lt" {
  name_prefix   = "three-tier-app-"
  image_id      = var.ami-id
  instance_type = "t2.micro"
  key_name      = var.key-name
  user_data     = filebase64("${path.module}/user-data.sh")

  network_interfaces {
    security_groups = [aws_security_group.app-instance-sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-app-instance"
    }
  }
}

resource "aws_autoscaling_group" "app-asg" {
  name                = "three-tier-app-asg"
  min_size            = 1
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.app-subnet-a.id, aws_subnet.app-subnet-b.id]

  launch_template {
    id      = aws_launch_template.app-lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app-tg.arn]
  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "three-tier-app-instance"
    propagate_at_launch = true
  }
}
