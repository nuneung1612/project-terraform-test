output "web_alb_dns_name" {
  description = "The DNS name of the Web Application Load Balancer."
  value       = aws_lb.web.dns_name
}

output "app_alb_dns_name" {
  description = "The DNS name of the Application Tier Load Balancer."
  value       = aws_lb.app.dns_name
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance."
  value       = aws_db_instance.default.endpoint
}
