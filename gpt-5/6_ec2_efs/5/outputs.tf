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

output "instance_private_ips" {
  description = "EC2 instance private IPs"
  value       = [for i in aws_instance.web : i.private_ip]
}

output "instance_public_ips" {
  description = "EC2 instance public IPs (Elastic IPs)"
  value       = [for e in aws_eip.web_eip : e.public_ip]
}

output "availability_zones_used" {
  description = "Availability Zones used by public subnets"
  value       = [for s in aws_subnet.public : s.availability_zone]
}
