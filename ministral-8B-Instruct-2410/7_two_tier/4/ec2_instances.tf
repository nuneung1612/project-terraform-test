resource "aws_instance" "web1_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_1.id
  availability_zone      = var.web1_az
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  tags = {
    Name = "web1_instance"
  }

  depends_on = [aws_vpc.project_vpc, aws_lb_target_group.project_tg]
}

resource "aws_instance" "web2_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_2.id
  availability_zone      = var.web2_az
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  tags = {
    Name = "web2_instance"
  }

  depends_on = [aws_vpc.project_vpc, aws_lb_target_group.project_tg]
}

resource "aws_lb_target_group_attachment" "web1_attachment" {
  target_group_arn = aws_lb_target_group.project_tg.arn
  target_id        = aws_instance.web1_instance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2_attachment" {
  target_group_arn = aws_lb_target_group.project_tg.arn
  target_id        = aws_instance.web2_instance.id
  port             = 80
}
