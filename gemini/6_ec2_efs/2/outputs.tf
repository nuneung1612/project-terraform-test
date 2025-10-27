output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "efs_id" {
  description = "The ID of the EFS file system."
  value       = aws_efs_file_system.main.id
}

output "efs_dns_name" {
  description = "The DNS name for the EFS file system."
  value       = aws_efs_file_system.main.dns_name
}

output "instance_details" {
  description = "Details of the EC2 instances, including public and private IPs."
  value = [
    for i in range(length(var.availability_zones)) : {
      instance_id = aws_instance.web[i].id
      public_ip   = aws_eip.main[i].public_ip
      private_ip  = aws_instance.web[i].private_ip
      az          = aws_instance.web[i].availability_zone
    }
  ]
}

output "availability_zones_used" {
  description = "The Availability Zones where resources were deployed."
  value       = var.availability_zones
}
