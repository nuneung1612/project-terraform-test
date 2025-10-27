resource "aws_instance" "web1" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  subnet_id     = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.public.id]
  tags = {
    Name = "web1"
  }
}

resource "aws_instance" "web2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  subnet_id     = aws_subnet.public[1].id
  vpc_security_group_ids = [aws_security_group.public.id]
  tags = {
    Name = "web2"
  }
}
