resource "aws_instance" "testinstance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet[0].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  key_name                    = var.key_name
  #   user_data = filebase64(var.user_data_file)
  # user_data = templatefile("${path.module}/user-data.sh", {
  #   efs_dns_name = aws_efs_file_system.main.ip_address
  # })
  tags = {
    Name = "testinstance"
  }
}
