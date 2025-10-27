// compute.tf
resource "aws_instance" "web" {
  count                       = length(aws_subnet.public)
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user-data.sh", {
    efs_id           = aws_efs_file_system.this.id
    mount_point      = var.efs_mount_point
    instance_num     = count.index + 1
    aws_region       = var.region
    efs_mount_target = aws_efs_mount_target.mt[count.index].ip_address
  })

  depends_on = [aws_efs_mount_target.mt]

  tags = merge(local.project_tags, {
    Name = "${var.project_name}-web-${count.index + 1}"
    Role = "web"
  })
}

resource "aws_eip" "web_eip" {
  count    = length(aws_instance.web)
  domain   = "vpc"
  instance = aws_instance.web[count.index].id

  tags = merge(local.project_tags, {
    Name = "${var.project_name}-eip-${count.index + 1}"
  })
}
