resource "aws_instance" "web1" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_1.id
  availability_zone = var.web1_az
  key_name      = var.key_name
  security_groups = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "web1_instance"
  }
}

resource "aws_instance" "web2" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_2.id
  availability_zone = var.web2_az
  key_name      = var.key_name
  security_groups = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "web2_instance"
  }
}
