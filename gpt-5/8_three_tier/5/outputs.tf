// outputs.tf
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "web_alb_dns_name" {
  value       = aws_lb.web.dns_name
  description = "Web ALB DNS name"
}

output "app_alb_dns_name" {
  value       = aws_lb.app.dns_name
  description = "App ALB DNS name"
}

output "rds_endpoint" {
  value       = aws_db_instance.mysql.address
  description = "RDS endpoint"
}
