# Create ec2 instances
resource "aws_instance" "web1" {
  ami           = var.ami
  instance_type = var.instance-type
  key_name        = var.key-name
  availability_zone = var.web1-az
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  subnet_id                   = aws_subnet.public_1.id
  associate_public_ip_address = true
  tags = {
    Name = "web1_instance"
  }
}

resource "aws_instance" "web2" {
  ami           = var.ami
  instance_type = var.instance-type
  key_name        = var.key-name
  availability_zone = var.web2-az
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  subnet_id                   = aws_subnet.public_2.id
  associate_public_ip_address = true
  tags = {
    Name = "web2_instance"
  }
}