# =========================================================
# efs.tf
# =========================================================
resource "aws_efs_file_system" "this" {
  encrypted = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-efs"
  })
}

# One mount target per public subnet / AZ
resource "aws_efs_mount_target" "this" {
  count           = length(aws_subnet.public)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = aws_subnet.public[count.index].id
  security_groups = [aws_security_group.efs.id]

  # Ensure IGW + routing + subnets exist first
  depends_on = [
    aws_internet_gateway.this,
    aws_route.public_inet,
    aws_route_table_association.public
  ]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-efs-mt-${var.azs[count.index]}"
    AZ   = var.azs[count.index]
  })
}
