# --- Security Groups ---
resource "aws_security_group" "web-alb-sg" {
  name        = "three-tier-web-alb-sg"
  description = "Allow HTTP inbound traffic to web ALB"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-web-alb-sg"
  }
}

resource "aws_security_group" "web-instance-sg" {
  name        = "three-tier-web-instance-sg"
  description = "Allow HTTP from ALB and SSH from anywhere"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    description     = "HTTP from Web ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-alb-sg.id]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-web-instance-sg"
  }
}

# --- Application Load Balancer ---
resource "aws_lb" "web-alb" {
  name               = "three-tier-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-alb-sg.id]
  subnets            = [aws_subnet.web-subnet-a.id, aws_subnet.web-subnet-b.id]

  tags = {
    Name = "three-tier-web-alb"
  }
}

resource "aws_lb_target_group" "web-tg" {
  name     = "three-tier-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.three-tier-vpc.id
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
    Name = "three-tier-web-tg"
  }
}

resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_lb.web-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
}

# --- Auto Scaling ---
resource "aws_launch_template" "web-lt" {
  name_prefix   = "three-tier-web-"
  image_id      = var.ami-id
  instance_type = "t2.micro"
  key_name      = var.key-name
  user_data     = filebase64("${path.module}/user-data.sh")

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web-instance-sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "three-tier-web-instance"
    }
  }
}

resource "aws_autoscaling_group" "web-asg" {
  name                = "three-tier-web-asg"
  min_size            = 1
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.web-subnet-a.id, aws_subnet.web-subnet-b.id]

  launch_template {
    id      = aws_launch_template.web-lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web-tg.arn]
  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "three-tier-web-instance"
    propagate_at_launch = true
  }
}
