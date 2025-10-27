# =========================================================
# outputs.tf
# =========================================================
output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "efs_id" {
  description = "EFS File System ID."
  value       = aws_efs_file_system.this.id
}

output "efs_dns_name" {
  description = "EFS DNS name."
  value       = aws_efs_file_system.this.dns_name
}

output "instance_ids" {
  description = "EC2 Instance IDs."
  value       = [for i in aws_instance.this : i.id]
}

output "instance_public_ips" {
  description = "Public IPs (Elastic IPs) of instances."
  value       = [for e in aws_eip.this : e.public_ip]
}

output "instance_private_ips" {
  description = "Private IPs of instances."
  value       = [for i in aws_instance.this : i.private_ip]
}

output "availability_zones_used" {
  description = "Availability Zones used for instances."
  value       = [for i in aws_instance.this : i.availability_zone]
}
