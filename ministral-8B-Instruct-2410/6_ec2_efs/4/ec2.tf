resource "aws_instance" "ec2" {
  count = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  associate_public_ip_address = true
  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name = "${var.project_name}-instance-${count.index + 1}"
  }

  depends_on = [
    aws_efs_mount_target.efs_mount_target
  ]

  provisioner "local-exec" {
    command = "echo ${self.id} > instance_ids.txt"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "instance" {
  count = 2
  vpc   = true
}

resource "aws_eip_association" "instance_eip" {
  count = 2
  instance_id   = aws_instance.ec2[count.index].id
  allocation_id = aws_eip.instance[count.index].id
}

output "instance_ids" {
  value = aws_instance.ec2[*].id
}

output "public_ips" {
  value = aws_eip.instance[*].public_ip
}

output "private_ips" {
  value = aws_instance.ec2[*].private_ip
}
