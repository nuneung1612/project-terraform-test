// compute.tf
resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = templatefile("${path.module}/user-data.sh", {
    efs_id            = aws_efs_file_system.this.id
    mount_point       = var.efs_mount_point
    instance_num      = count.index + 1
    aws_region        = var.aws_region
    efs_mount_target  = aws_efs_mount_target.this[count.index].ip_address
  })

  user_data_replace_on_change = true

  depends_on = [
    aws_efs_mount_target.this
  ]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-web-${var.azs[count.index]}"
    AZ   = var.azs[count.index]
    Role = "web"
  })
}

resource "aws_eip" "web" {
  count  = var.instance_count
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-eip-${var.azs[count.index]}"
    AZ   = var.azs[count.index]
  })
}

resource "aws_eip_association" "web" {
  count         = var.instance_count
  allocation_id = aws_eip.web[count.index].id
  instance_id   = aws_instance.web[count.index].id
}
