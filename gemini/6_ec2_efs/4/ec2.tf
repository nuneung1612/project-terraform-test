data "template_file" "user_data" {
  count    = length(var.public_subnet_cidrs)
  template = file("user-data.sh")

  vars = {
    efs_id           = aws_efs_file_system.main.id
    mount_point      = var.efs_mount_point
    instance_num     = count.index + 1
    aws_region       = var.aws_region
    efs_mount_target = aws_efs_mount_target.main[count.index].ip_address
  }
}

resource "aws_instance" "web" {
  count                       = length(var.public_subnet_cidrs)
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  user_data                   = data.template_file.user_data[count.index].rendered
  user_data_replace_on_change = true

  depends_on = [aws_efs_mount_target.main]

  tags = {
    Name = "${var.project_name}-instance-${count.index + 1}"
  }
}

resource "aws_eip" "main" {
  count    = length(var.public_subnet_cidrs)
  instance = aws_instance.web[count.index].id
  domain      = "vpc"

  tags = {
    Name = "${var.project_name}-eip-${count.index + 1}"
  }
}
