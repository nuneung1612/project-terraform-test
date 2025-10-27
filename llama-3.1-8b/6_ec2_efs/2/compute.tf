resource "aws_instance" "main" {
  count                  = var.num_instances
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = aws_subnet.public[count % length(var.subnet_cidrs)].id

  ebs_block_device {
    device_name = "/dev/sdh"
    volume_size = 30
  }

  tags = {
    Name = "${var.project_name}-ec2-instance-${count.index + 1}"
  }

  user_data_replace_on_change = true

  user_data = <<EOF
#!/bin/bash
export EFS_ID=${aws_efs_file_system.main.id}
export MOUNT_POINT=${var.efs_mount_point}
export INSTANCE_NUM=${count.index + 1}
export AWS_REGION=${var.aws_region}
export EFS_MOUNT_TARGET_IP_ADDRESS=${aws_efs_mount_target.main[count % length(var.availability_zones)].ip_address}
EOF
}

resource "aws_eip" "main" {
  count    = var.num_instances
  vpc      = true
  instance = aws_instance.main[count.index].id
}
