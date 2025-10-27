variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "efs_mount_point" {
  description = "EFS mount point"
  type        = string
}

variable "efs_id" {
  description = "EFS ID"
  type        = string
}

variable "efs_mount_target" {
  description = "EFS mount target"
  type        = list(string)
}

resource "aws_instance" "instance" {
  count         = length(var.availability_zones)
  ami           = var.ami_id
  instance_type = var.instance_type
  availability_zone = var.availability_zones[count.index]

  user_data = file("user-data.sh")

  network_interface {
    device_index = 0
    associate_public_ip_address = true
  }

  tags = {
    Name = "${var.project_name}-instance-${count.index}"
  }

  depends_on = [module.network.efs_mount_target]
}

resource "aws_eip" "instance_eip" {
  count = length(var.availability_zones)
  instance = aws_instance.instance[count.index].id
  vpc      = true
}

output "instance_ids" {
  value = aws_instance.instance[*].id
}

output "public_ips" {
  value = aws_eip.instance_eip[*].public_ip
}

output "private_ips" {
  value = aws_instance.instance[*].private_ip
}
