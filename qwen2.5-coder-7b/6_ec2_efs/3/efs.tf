resource "aws_efs_file_system" "main" {
  encryption_type = "KMS"

  tags = {
    Name = "${local.project_name}-efs"
  }
}

resource "aws_efs_mount_target" "mount_target" {
  count         = length(aws_subnet.public)
  file_system_id = aws_efs_file_system.main.id
  subnet_id      = element(aws_subnet.public.*.id, count.index)

  tags = {
    Name = "${local.project_name}-efs-mt-${count.index + 1}"
  }
}

resource "aws_efs_access_point" "access_point" {
  file_system_id = aws_efs_file_system.main.id

  root_directory {
    path = "/mnt/efs"
  }

  tags = {
    Name = "${local.project_name}-efs-ap"
  }
}
