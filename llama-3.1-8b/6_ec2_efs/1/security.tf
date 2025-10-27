resource "aws_efs_access_point" "main" {
  file_system_id = aws_efs_file_system.main.id

  posix_user {
    uid = 1001
    gid = 1001
  }

  root_directory {
    path = "/"
  }
}
