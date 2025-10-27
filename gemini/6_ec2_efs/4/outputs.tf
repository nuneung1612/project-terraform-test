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

output "instance_ids" {
  description = "A list of the EC2 instance IDs."
  value       = aws_instance.web.*.id
}

output "public_ips" {
  description = "A list of the public IP addresses of the EC2 instances."
  value       = aws_eip.main.*.public_ip
}

output "private_ips" {
  description = "A list of the private IP addresses of the EC2 instances."
  value       = aws_instance.web.*.private_ip
}

output "availability_zones_used" {
  description = "The availability zones where resources were deployed."
  value       = var.availability_zones
}
