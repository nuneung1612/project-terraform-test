############################
# outputs.tf
############################
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
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
  description = "IDs of EC2 instances"
  value       = [for i in aws_instance.web : i.id]
}

output "instance_public_ips" {
  description = "Public IPs of EC2 instances (Elastic IPs)"
  value       = [for e in aws_eip.web : e.public_ip]
}

output "instance_private_ips" {
  description = "Private IPs of EC2 instances"
  value       = [for i in aws_instance.web : i.private_ip]
}

output "availability_zones_used" {
  description = "Availability zones used for public subnets/instances"
  value       = var.availability_zones
}
