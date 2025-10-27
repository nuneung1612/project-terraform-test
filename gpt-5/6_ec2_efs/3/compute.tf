locals {
  instance_count = 2
}

resource "aws_instance" "web" {
  count                       = local.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  user_data                   = templatefile("${path.module}/user-data.sh", {
    efs_id           = aws_efs_file_system.this.id
    mount_point      = var.efs_mount_point
    instance_num     = count.index + 1
    aws_region       = data.aws_region.current.name
    efs_mount_target = tolist(aws_efs_mount_target.mt[*].ip_address)[count.index]
  })
  user_data_replace_on_change = true

  tags = {
    Name    = "${var.project_name}-web-${var.azs[count.index]}"
    Project = var.project_name
    AZ      = var.azs[count.index]
    Role    = "web"
  }

  depends_on = [aws_efs_mount_target.mt]
}

resource "aws_eip" "web_eip" {
  count  = local.instance_count
  domain = "vpc"
  instance = aws_instance.web[count.index].id

  tags = {
    Name    = "${var.project_name}-eip-${var.azs[count.index]}"
    Project = var.project_name
    AZ      = var.azs[count.index]
  }
}
