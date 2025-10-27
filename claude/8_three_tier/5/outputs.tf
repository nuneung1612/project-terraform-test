output "web-alb-dns" {
  description = "DNS name of web tier ALB"
  value       = aws_lb.three-tier-web-alb.dns_name
}

output "app-alb-dns" {
  description = "DNS name of app tier ALB"
  value       = aws_lb.three-tier-app-alb.dns_name
}

output "rds-endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.three-tier-db.endpoint
  sensitive   = true
}