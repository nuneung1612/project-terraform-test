resource "aws_efs_file_system" "efs" {
  creation_token = var.project_name
  encrypted      = true

  tags = {
    Name = "${var.project_name}-efs"
  }
}

resource "aws_efs_mount_target" "main" {
  count           = length(var.availability_zones)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = element(aws_subnet.public[*].id, count.index)
  security_groups = [aws_security_group.efs.id]

  depends_on = [aws_subnet.public]
}

resource "aws_efs_lifecycle_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id
  policy         = data.aws_iam_policy_document.efs_lifecycle_policy.json
}

data "aws_iam_policy_document" "efs_lifecycle_policy" {
  statement {
    sid       = "Transition to Infrequent Access"
    actions   = ["efs:TransitionToIA"]
    resources = [aws_efs_file_system.efs.arn]

    condition {
      test     = "StringEquals"
      variable = "transitionToIA"
      values   = ["true"]
    }
  }
}
