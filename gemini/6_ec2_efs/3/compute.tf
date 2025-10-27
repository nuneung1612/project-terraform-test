# Elastic IPs for the EC2 instances
resource "aws_eip" "main" {
  count = length(var.availability_zones)

  tags = {
    Name = "${var.project_name}-eip-${count.index + 1}"
  }
}

# EC2 instances in each AZ
resource "aws_instance" "web" {
  count                       = length(var.availability_zones)
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user-data.sh", {
    efs_id           = aws_efs_file_system.main.id
    mount_point      = var.efs_mount_point
    instance_num     = count.index + 1
    aws_region       = var.aws_region
    efs_mount_target = aws_efs_mount_target.main[count.index].ip_address
  })

  # Ensure EFS mount targets are created before the instances
  depends_on = [aws_efs_mount_target.main]

  tags = {
    Name = "${var.project_name}-instance-${count.index + 1}"
    AZ   = element(var.availability_zones, count.index)
  }
}

# Associate Elastic IPs with EC2 instances
resource "aws_eip_association" "main" {
  count         = length(var.availability_zones)
  instance_id   = aws_instance.web[count.index].id
  allocation_id = aws_eip.main[count.index].id
}
