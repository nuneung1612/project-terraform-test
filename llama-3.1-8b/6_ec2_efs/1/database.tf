resource "aws_efs_file_system" "main" {
  creation_token   = "${var.project_name}-efs"
  performance_mode = "generalPurpose"

  tags = {
    Name = "${var.project_name}-efs"
  }
}

resource "aws_efs_mount_target" "main" {
  file_system_id = aws_efs_file_system.main.id
  subnet_id      = aws_subnet.public[0].id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "main-secondary" {
  file_system_id = aws_efs_file_system.main.id
  subnet_id      = aws_subnet.public[1].id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_lifecycle_policy" "main" {
  file_system_id = aws_efs_file_system.main.id

  policy {
    transition_to_ia = {
      days = 30
    }
  }
}
