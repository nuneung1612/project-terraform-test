# Create EC2 instances for web servers
resource "aws_instance" "web_servers" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.ec2_instance_type
  key_name      = var.key_pair_name
  subnet_id     = aws_subnet.public_subnets[count.index].id
  security_groups = [aws_security_group.public_sg.id]

  tags = {
    Name = "web-server-${count.index + 1}"
  }
}