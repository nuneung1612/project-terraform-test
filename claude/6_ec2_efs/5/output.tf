# outputs.tf
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "efs_id" {
  description = "EFS file system ID"
  value       = aws_efs_file_system.main.id
}

output "efs_dns_name" {
  description = "EFS DNS name"
  value       = aws_efs_file_system.main.dns_name
}

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.main[*].id
}

output "instance_public_ips" {
  description = "EC2 instance public IPs"
  value       = aws_eip.main[*].public_ip
}

output "instance_private_ips" {
  description = "EC2 instance private IPs"
  value       = aws_instance.main[*].private_ip
}

output "availability_zones" {
  description = "Availability zones used"
  value       = aws_subnet.public[*].availability_zone
}