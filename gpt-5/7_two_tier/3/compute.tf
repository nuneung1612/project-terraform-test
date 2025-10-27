resource "aws_instance" "web1" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  availability_zone           = var.web1_az

  tags = {
    Name = "web1_instance"
  }

  depends_on = [aws_route_table_association.public_1_assoc]
}

resource "aws_instance" "web2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_2.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  availability_zone           = var.web2_az

  tags = {
    Name = "web2_instance"
  }

  depends_on = [aws_route_table_association.public_2_assoc]
}