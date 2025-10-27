resource "aws_instance" "web" {
  count                  = 2
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  #key_name = var.key_name

  user_data = templatefile("${path.module}/user-data.sh", {
    efs_id           = aws_efs_file_system.main.id
    mount_point      = var.efs_mount_point
    instance_num     = count.index + 1
    aws_region       = var.aws_region
    efs_mount_target = aws_efs_mount_target.main[count.index].ip_address
  })

  user_data_replace_on_change = true

  depends_on = [
    aws_efs_mount_target.main
  ]

  tags = {
    Name = "${var.project_name}-instance-${count.index + 1}"
    AZ   = var.availability_zones[count.index]
  }
}

resource "aws_eip" "web" {
  count    = 2
  instance = aws_instance.web[count.index].id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip-${count.index + 1}"
  }
}