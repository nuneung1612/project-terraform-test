resource "aws_efs_file_system" "main" {
  creation_token = "my-efs-file-system"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = true
  lifecycle_policy {
    transition_to_ia = 30
  }
  tags = {
    Name = var.project_name
  }
}

resource "aws_efs_mount_target" "main" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.public[0].id
  security_groups = [aws_security_group.efs.id]
  depends_on = [aws_efs_file_system.main]
}

resource "aws_efs_mount_target" "main2" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.public[1].id
  security_groups = [aws_security_group.efs.id]
  depends_on = [aws_efs_file_system.main]
}

resource "aws_instance" "instance" {
  count = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id = aws_subnet.public[count.index].id
  key_name = "my-key"
  user_data = <<-EOF
    #!/bin/bash
    echo "efs_id = ${var.efs_id}" >> /mnt/efs/user-data.sh
    echo "efs_mount_point = ${var.efs_mount_point}" >> /mnt/efs/user-data.sh
    echo "instance_num = ${count.index+1}" >> /mnt/efs/user-data.sh
    echo "aws_region = ${var.aws_region}" >> /mnt/efs/user-data.sh
    echo "efs_mount_target_ip = ${aws_efs_mount_target.main[count.index].ip_address}" >> /mnt/efs/user-data.sh
  EOF
  tags = {
    Name = "${var.project_name}-instance-${count.index+1}"
  }
  depends_on = [aws_efs_mount_target.main, aws_efs_mount_target.main2]
}

resource "aws_eip" "instance" {
  count = 2
  instance = aws_instance.instance[count.index].id
  vpc = true
}

resource "aws_eip_association" "instance" {
  count = 2
  instance_id = aws_instance.instance[count.index].id
  allocation_id = aws_eip.instance[count.index].id
}
