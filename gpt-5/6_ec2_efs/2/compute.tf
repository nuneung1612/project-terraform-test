# =========================================================
# compute.tf
# =========================================================
# Elastic IPs for each instance
resource "aws_eip" "this" {
  count = var.instance_count
  vpc   = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-eip-${var.azs[count.index]}"
    AZ   = var.azs[count.index]
  })
}

# EC2 Instances across AZs/subnets
resource "aws_instance" "this" {
  count                       = var.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  # Pass variables to existing user-data.sh template
  user_data = templatefile("${path.module}/user-data.sh", {
    efs_id           = aws_efs_file_system.this.id
    mount_point      = var.efs_mount_point
    instance_num     = count.index + 1
    aws_region       = var.region
    efs_mount_target = aws_efs_mount_target.this[count.index].ip_address
  })

  user_data_replace_on_change = true

  # Ensure EFS mount targets are ready before instances
  depends_on = [
    aws_efs_mount_target.this
  ]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-ec2-${var.azs[count.index]}"
    AZ   = var.azs[count.index]
    Role = "web"
  })
}

# Associate each EIP to its corresponding instance
resource "aws_eip_association" "this" {
  count         = var.instance_count
  instance_id   = aws_instance.this[count.index].id
  allocation_id = aws_eip.this[count.index].id

  depends_on = [aws_instance.this]
}
