output "web-alb-dns-name" {
  description = "DNS name of the web tier ALB"
  value       = aws_lb.three-tier-web-alb.dns_name
}

output "app-alb-dns-name" {
  description = "DNS name of the app tier ALB"
  value       = aws_lb.three-tier-app-alb.dns_name
}

output "rds-endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.three-tier-rds.endpoint
  sensitive   = true
}

output "vpc-id" {
  description = "VPC ID"
  value       = aws_vpc.three-tier-vpc.id
}