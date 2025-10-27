// outputs.tf
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "efs_id" {
  description = "EFS File System ID"
  value       = aws_efs_file_system.this.id
}

output "efs_dns_name" {
  description = "EFS DNS name"
  value       = aws_efs_file_system.this.dns_name
}

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = [for i in aws_instance.web : i.id]
}

output "instance_public_ips" {
  description = "Public IPs of instances (EIPs)"
  value       = [for a in aws_eip_association.web : aws_eip.web[a.count.index].public_ip]
}

output "instance_private_ips" {
  description = "Private IPs of instances"
  value       = [for i in aws_instance.web : i.private_ip]
}

output "availability_zones_used" {
  description = "AZs used by resources"
  value       = var.azs
}
