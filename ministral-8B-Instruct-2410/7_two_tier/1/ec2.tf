resource "aws_instance" "web1" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet_1.id
  key_name      = var.key_pair_name
  associate_public_ip_address = true
  tags = {
    Name = "web1"
  }
}

resource "aws_instance" "web2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet_2.id
  key_name      = var.key_pair_name
  associate_public_ip_address = true
  tags = {
    Name = "web2"
  }
}
