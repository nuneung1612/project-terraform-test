############################
# compute.tf
############################
locals {
  instance_count = length(aws_subnet.public)
}

resource "aws_instance" "web" {
  count                       = local.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  user_data                   = templatefile("${path.module}/user-data.sh", {
    efs_id            = aws_efs_file_system.this.id
    mount_point       = var.efs_mount_point
    instance_num      = tostring(count.index + 1)
    aws_region        = var.region
    efs_mount_target  = aws_efs_mount_target.mt[count.index].ip_address
  })
  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required" # Enforce IMDSv2
  }

  tags = {
    Name = "${var.project_name}-web-${count.index + 1}"
    Role = "web"
  }

  depends_on = [
    aws_efs_mount_target.mt
  ]
}

resource "aws_eip" "web" {
  count    = local.instance_count
  domain   = "vpc"
  instance = aws_instance.web[count.index].id

  tags = {
    Name = "${var.project_name}-eip-${count.index + 1}"
  }
}
