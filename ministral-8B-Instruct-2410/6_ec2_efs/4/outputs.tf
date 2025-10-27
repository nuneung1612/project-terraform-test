output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_dns_name" {
  description = "The DNS name of the VPC"
  value       = aws_vpc.main.dns_support
}

output "efs_id" {
  description = "The ID of the EFS"
  value       = aws_efs_file_system.efs.id
}

output "instance_ids" {
  description = "The IDs of the EC2 instances"
  value       = aws_instance.ec2[*].id
}

output "public_ips" {
  description = "The public IPs of the EC2 instances"
  value       = aws_eip.instance[*].public_ip
}

output "private_ips" {
  description = "The private IPs of the EC2 instances"
  value       = aws_instance.ec2[*].private_ip
}

output "availability_zones" {
  description = "The availability zones used"
  value       = aws_subnet.public[*].availability_zone
}
