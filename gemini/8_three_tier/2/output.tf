output "web_alb_dns_name" {
  description = "The DNS name of the web tier Application Load Balancer."
  value       = aws_lb.web.dns_name
}

output "app_alb_dns_name" {
  description = "The DNS name of the application tier Application Load Balancer."
  value       = aws_lb.app.dns_name
}
