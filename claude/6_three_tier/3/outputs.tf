# outputs.tf
output "vpc-id" {
  description = "VPC ID"
  value       = aws_vpc.three-tier-vpc.id
}

output "web-alb-dns" {
  description = "Web tier ALB DNS name"
  value       = aws_lb.three-tier-web-alb.dns_name
}

output "app-alb-dns" {
  description = "App tier ALB DNS name"
  value       = aws_lb.three-tier-app-alb.dns_name
}

output "rds-endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.three-tier-rds.endpoint
}