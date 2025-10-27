resource "aws_efs_file_system" "efs" {
  creation_token   = "efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"
  tags = {
    Name = "EFS"
  }
}

resource "aws_efs_mount_target" "efs-mt" {
  count           = length(data.aws_availability_zones.available.names)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.subnet[count.index].id
  security_groups = [aws_security_group.efs.id]
}

# Creating Mount Point for EFS
resource "null_resource" "configure_nfs" {
  depends_on = [aws_efs_mount_target.efs-mt]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key)
    host        = aws_instance.testinstance.public_ip
    timeout     = "20s"
  }


  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y -q",
      "sleep 15",
      "sudo yum install php  -y -q ",
      "sleep 5",
      "sudo systemctl start httpd",
      "sleep 5",
      "sudo systemctl enable httpd",
      "sleep 5",
      "sudo yum install nfs-utils -y -q ", # Amazon ami has pre installed nfs utils
      "sleep 15",
      "sudo service rpcbind restart",
      "sleep 15",
      # Mounting Efs 
      "sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/  /var/www/html",
      "sleep 15",
      "sudo chmod go+rw /var/www/html",
      "sudo bash -c 'echo Welcome  > /var/www/html/index.html'",
    ]
  }
}