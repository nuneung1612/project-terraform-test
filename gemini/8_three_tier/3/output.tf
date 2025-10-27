output "web-alb-dns-name" {
  description = "The DNS name of the Web Tier Application Load Balancer."
  value       = aws_lb.web-alb.dns_name
}

output "app-alb-dns-name" {
  description = "The DNS name of the Application Tier Application Load Balancer."
  value       = aws_lb.app-alb.dns_name
}
