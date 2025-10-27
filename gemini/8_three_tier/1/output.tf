output "web_alb_dns_name" {
  description = "The DNS name of the web tier Application Load Balancer."
  value       = aws_lb.web.dns_name
}
