# EC2 Instances, one in each Availability Zone
resource "aws_instance" "web" {
  count                       = length(var.availability_zones)
  ami                         = var.ami_id
  instance_type               = var.instance_type
  availability_zone           = var.availability_zones[count.index]
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  user_data_replace_on_change = true

  # The user_data assumes a script named 'user-data.sh' exists in the same directory.
  user_data = templatefile("${path.module}/user-data.sh", {
    efs_id           = aws_efs_file_system.main.id
    mount_point      = var.efs_mount_point
    instance_num     = count.index + 1
    aws_region       = var.aws_region
    efs_mount_target = aws_efs_mount_target.main[count.index].ip_address
  })

  # Instances should only be created after the EFS mount targets are available.
  depends_on = [
    aws_efs_mount_target.main
  ]

  tags = {
    Name = "${var.project_name}-instance-${count.index + 1}"
    AZ   = var.availability_zones[count.index]
  }
}

# Elastic IPs for the EC2 instances
resource "aws_eip" "main" {
  count    = length(var.availability_zones)
  instance = aws_instance.web[count.index].id
  # The 'domain' attribute is deprecated for 'vpc'
  # and this syntax is correct for AWS provider v4.0+
  # 'vpc' = true is still valid but this is more explicit.
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-eip-${count.index + 1}"
  }
}
