resource "aws_efs_file_system" "main" {
  creation_token = "${var.project_name}-efs"
  throughput_mode = "bursting"
  performance_mode = "generalPurpose"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "${var.project_name}-efs"
  }
}

resource "aws_efs_mount_target" "main" {
  count           = length(var.availability_zones)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.public[count.index].id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target_security_group" "main" {
  count = length(var.availability_zones)
  file_system_id = aws_efs_file_system.main.id
  security_group_id = aws_security_group.efs.id
  ip_address = aws_subnet.public[count.index].primary_ip_address
}
