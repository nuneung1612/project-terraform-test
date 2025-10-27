resource "aws_efs_file_system" "main" {
  encrypted = true

  lifecycle_policy {
    transition_to_ia = "AFTER_${var.efs_transition_days}_DAYS"
  }

  tags = {
    Name = "${var.project_name}-efs"
  }
}

resource "aws_efs_mount_target" "main" {
  count           = length(var.public_subnet_cidrs)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.public[count.index].id
  security_groups = [aws_security_group.efs.id]
}
