resource "aws_instance" "web1" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  tags = {
    Name = "web1_instance"
  }

  depends_on = [aws_subnet.public_1]
}

resource "aws_instance" "web2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_2.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  tags = {
    Name = "web2_instance"
  }

  depends_on = [aws_subnet.public_2]
}
