output "vpc-id" {
  description = "VPC ID"
  value       = aws_vpc.three-tier-vpc.id
}

output "web-alb-dns-name" {
  description = "Web tier ALB DNS name"
  value       = aws_lb.three-tier-web-alb.dns_name
}

output "app-alb-dns-name" {
  description = "App tier ALB DNS name"
  value       = aws_lb.three-tier-app-alb.dns_name
}

output "rds-endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.three-tier-rds.endpoint
  sensitive   = true
}

output "rds-address" {
  description = "RDS instance address"
  value       = aws_db_instance.three-tier-rds.address
  sensitive   = true
}

output "nat-gateway-public-ip" {
  description = "NAT Gateway public IP"
  value       = aws_eip.three-tier-nat-eip.public_ip
}