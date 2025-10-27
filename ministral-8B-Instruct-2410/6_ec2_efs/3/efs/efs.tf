variable "efs_mount_point" {
  description = "EFS mount point"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

resource "aws_efs_file_system" "efs" {
  creation_token = "${var.project_name}-efs"
  encrypted      = true
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count           = length(var.availability_zones)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = module.network.public_subnet[count.index].id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_lifecycle_policy" "lifecycle" {
  file_system_id = aws_efs_file_system.efs.id
  policy         = <<POLICY
{
  "Rules": [
    {
      "ID": "TransitionToInfrequentAccess",
      "Description": "Transition to Infrequent Access after 30 days",
      "TransitionToInfrequentAccess": {
        "Days": 30
      }
    }
  ]
}
POLICY
}
