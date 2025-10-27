resource "aws_efs_file_system" "example" {
  creation_token = "${var.project_name}-efs"

  tags = {
    Name = "${var.project_name}-efs"
  }
}

resource "aws_efs_mount_target" "example" {
  count           = length(var.availability_zones)
  file_system_id  = aws_efs_file_system.example.id
  subnet_id       = var.availability_zones[count.index] == var.availability_zones[0]? aws_subnet.public_subnet1.id : aws_subnet.public_subnet2.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_lifecycle_policy" "example" {
  file_system_id = aws_efs_file_system.example.id

  transition_to_ia {
    days = 30
  }
}
