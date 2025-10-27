resource "aws_instance" "main" {
  count         = var.instance_num
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(aws_subnet.public[*].id, count.index % length(aws_subnet.public))
  user_data     = file(var.user_data)

  tags = {
    Name = "${var.project_name}-instance-${count.index}"
  }

  provisioner "local-exec" {
    command = "echo ${aws_efs_mount_target.main[count.index].ip_address} > efs_mount_target_${count.index}"
  }

  depends_on = [
    aws_efs_mount_target.main
  ]
}

resource "aws_eip" "main" {
  count = var.instance_num
  vpc   = true
}

resource "aws_eip_association" "main" {
  count       = var.instance_num
  instance_id = element(aws_instance.main[*].id, count.index)
  allocation_id = element(aws_eip.main[*].id, count.index)
}
