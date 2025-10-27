# -----------------------------------------------------------------------------
# EC2 Bastion Instance (Public Subnet)
# -----------------------------------------------------------------------------
resource "aws_instance" "bastion_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  
  tags = {
    Name = "Bastion-Server"
  }
}

# -----------------------------------------------------------------------------
# EC2 Application Server (Private Subnet)
# -----------------------------------------------------------------------------
resource "aws_instance" "app_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  # No public IP assigned in private subnet

  tags = {
    Name = "Application-Server"
  }
}
