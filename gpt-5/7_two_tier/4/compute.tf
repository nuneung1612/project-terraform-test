# compute.tf
resource "aws_instance" "web1" {
  ami                         = var.web_ami_id
  instance_type               = var.web_instance_type
  availability_zone           = var.web1_az
  subnet_id                   = aws_subnet.public_1.id
  key_name                    = var.web_key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public_sg.id]

  tags = {
    Name = "web1_instance"
    Role = "web"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "web2" {
  ami                         = var.web_ami_id
  instance_type               = var.web_instance_type
  availability_zone           = var.web2_az
  subnet_id                   = aws_subnet.public_2.id
  key_name                    = var.web_key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public_sg.id]

  tags = {
    Name = "web2_instance"
    Role = "web"
  }

  lifecycle {
    create_before_destroy = true
  }
}
