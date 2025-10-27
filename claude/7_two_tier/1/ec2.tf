resource "aws_instance" "web1" {
  ami                         = var.ami_id
  instance_type               = var.ec2_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = {
    Name    = "${var.project_name}-web1"
    Project = var.project_name
  }
}

resource "aws_instance" "web2" {
  ami                         = var.ami_id
  instance_type               = var.ec2_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.public_2.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = {
    Name    = "${var.project_name}-web2"
    Project = var.project_name
  }
}