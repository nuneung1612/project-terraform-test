# Template for user data script
data "template_file" "user_data" {
  count    = length(var.availability_zones)
  template = file("user-data.sh")

  vars = {
    efs_id           = aws_efs_file_system.main_efs.id
    mount_point      = var.efs_mount_point
    instance_num     = count.index + 1
    aws_region       = var.aws_region
    efs_mount_target = aws_efs_mount_target.efs_mount_targets[count.index].ip_address
  }
}

# EC2 Instances
resource "aws_instance" "web_servers" {
  count = length(var.availability_zones)

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnets[count.index].id
  availability_zone           = var.availability_zones[count.index]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  user_data_replace_on_change = true
  user_data                   = data.template_file.user_data[count.index].rendered

  depends_on = [aws_efs_mount_target.efs_mount_targets]

  tags = {
    Name = "${var.project_name}-EC2-${var.availability_zones[count.index]}"
    AZ   = var.availability_zones[count.index]
  }
}

# Elastic IPs for each instance
resource "aws_eip" "instance_eips" {
  count = length(var.availability_zones)
  # The 'instance' argument is deprecated, associate in a separate resource
  # instance = aws_instance.web_servers[count.index].id
  vpc = true
  tags = {
    Name = "${var.project_name}-EIP-${count.index + 1}"
  }
}

# Associate Elastic IPs with EC2 Instances
resource "aws_eip_association" "eip_assoc" {
  count         = length(var.availability_zones)
  instance_id   = aws_instance.web_servers[count.index].id
  allocation_id = aws_eip.instance_eips[count.index].id
}
