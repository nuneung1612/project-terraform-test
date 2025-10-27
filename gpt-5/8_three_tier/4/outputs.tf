# ===================================================================
# outputs.tf
# ===================================================================

output "web_alb_dns_name" {
  description = "DNS name of Web ALB"
  value       = aws_lb.web.dns_name
}

output "app_alb_dns_name" {
  description = "DNS name of App ALB"
  value       = aws_lb.app.dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.this.address
  sensitive   = false
}




