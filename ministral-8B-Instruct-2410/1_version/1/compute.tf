resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id = aws_subnet.main.id

  tags = {
    Name = "web-server"
  }

  depends_on = [aws_subnet.main]
}
