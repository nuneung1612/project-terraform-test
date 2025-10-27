resource "aws_instance" "example" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = count.index == 0? aws_subnet.public_subnet1.id : aws_subnet.public_subnet2.id
  key_name      = "your-key-name"

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name = "${var.project_name}-instance-${count.index}"
  }

  depends_on = [aws_efs_mount_target.example]
}

resource "aws_eip" "example" {
  count = 2
  vpc   = true
}

resource "aws_instance" "example" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = count.index == 0? aws_subnet.public_subnet1.id : aws_subnet.public_subnet2.id
  key_name      = "your-key-name"

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name = "${var.project_name}-instance-${count.index}"
  }

  depends_on = [aws_efs_mount_target.example]

  user_data_replace_on_change = true
}

resource "aws_eip_association" "example" {
  count         = 2
  instance_id   = aws_instance.example[count.index].id
  allocation_id = aws_eip.example[count.index].id
}
