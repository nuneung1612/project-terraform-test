resource "aws_instance" "ec2" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  key_name      = var.key_name
  user_data     = base64encode(file("user-data.sh"))

  tags = {
    Name = "${local.project_name}-ec2-${count.index + 1}"
  }

  depends_on = [aws_efs_file_system.main]
}

resource "aws_eip" "instance" {
  count = 2

  association {
    instance = aws_instance.ec2[count.index].id
  }
}
