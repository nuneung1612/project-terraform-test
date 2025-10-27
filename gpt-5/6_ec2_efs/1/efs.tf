// efs.tf
resource "aws_efs_file_system" "this" {
  encrypted       = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-efs"
  })
}

resource "aws_efs_mount_target" "this" {
  count          = length(aws_subnet.public)
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = aws_subnet.public[count.index].id
  security_groups = [
    aws_security_group.efs.id
  ]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-efs-mt-${var.azs[count.index]}"
    AZ   = var.azs[count.index]
  })
}
