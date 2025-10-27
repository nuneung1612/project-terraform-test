output "vpc_id" {
  value = aws_vpc.main.id
}

output "web_alb_dns" {
  value = aws_alb.web.dns_name
}

output "app_alb_dns" {
  value = aws_alb.app.dns_name
}

output "db_instance_id" {
  value = aws_db_instance.main.id
}
