# EFS File System
resource "aws_efs_file_system" "main_efs" {
  encrypted = true
  # performance_mode can be generalPurpose (default) or maxIO
  # throughput_mode can be bursting (default) or provisioned

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "${var.project_name}-EFS"
  }
}

# EFS Mount Targets in each public subnet
resource "aws_efs_mount_target" "efs_mount_targets" {
  count           = length(aws_subnet.public_subnets)
  file_system_id  = aws_efs_file_system.main_efs.id
  subnet_id       = aws_subnet.public_subnets[count.index].id
  security_groups = [aws_security_group.efs_sg.id]

  depends_on = [aws_efs_file_system.main_efs]
}
