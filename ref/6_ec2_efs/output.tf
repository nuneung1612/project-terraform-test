output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "efs_id" {
  description = "EFS File System ID"
  value       = aws_efs_file_system.main.id
}

output "efs_dns_name" {
  description = "EFS DNS Name"
  value       = aws_efs_file_system.main.dns_name
}

output "instance_ids" {
  description = "EC2 Instance IDs"
  value       = aws_instance.web[*].id
}

output "instance_public_ips" {
  description = "EC2 Instance Public IPs"
  value       = aws_eip.web[*].public_ip
}

output "instance_private_ips" {
  description = "EC2 Instance Private IPs"
  value       = aws_instance.web[*].private_ip
}

output "availability_zones" {
  description = "Availability Zones used"
  value       = aws_instance.web[*].availability_zone
}