resource "aws_instance" "web" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type_ec2
  key_name      = var.key_pair_name
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<html><body><h1>Web Server ${count.index + 1}</h1></body></html>" > /var/www/html/index.html
              EOF

  tags = {
    Name = format("web-server-%d", count.index + 1)
  }

  vpc_security_group_ids = [aws_security_group.public.id]
}

resource "aws_lb" "main" {
  name               = "two-tier-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "main-alb"
  }
}

resource "aws_target_group" "http" {
  name     = "two-tier-http-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "http-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_target_group.http.arn
  }
}

resource "aws_target_group_attachment" "web" {
  count            = length(aws_instance.web)
  target_group_arn = aws_target_group.http.arn
  target_id        = element(aws_instance.web[*].primary_network_interface_id, count.index)
}
