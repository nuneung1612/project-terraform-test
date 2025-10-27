output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main_vpc.id
}

output "efs_id" {
  description = "The ID of the EFS file system."
  value       = aws_efs_file_system.main_efs.id
}

output "efs_dns_name" {
  description = "The DNS name for the EFS file system."
  value       = aws_efs_file_system.main_efs.dns_name
}

output "instance_ids" {
  description = "A list of the EC2 instance IDs."
  value       = aws_instance.web_servers[*].id
}

output "instance_public_ips" {
  description = "A list of the public IP addresses of the EC2 instances."
  value       = aws_eip.instance_eips[*].public_ip
}

output "instance_private_ips" {
  description = "A list of the private IP addresses of the EC2 instances."
  value       = aws_instance.web_servers[*].private_ip
}

output "availability_zones_used" {
  description = "The Availability Zones where resources were deployed."
  value       = var.availability_zones
}
