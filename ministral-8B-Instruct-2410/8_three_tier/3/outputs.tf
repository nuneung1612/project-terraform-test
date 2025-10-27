output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "web_alb_dns" {
  description = "DNS name of the web tier ALB"
  value       = aws_elb.web.dns_name
}

output "app_alb_dns" {
  description = "DNS name of the app tier ALB"
  value       = aws_elb.app.dns_name
}

output "db_endpoint" {
  description = "Endpoint of the RDS cluster"
  value       = aws_rds_cluster.mydb.endpoint
}
