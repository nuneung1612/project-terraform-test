output "instance_id" {
  description = "The ID of the web instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "The public IP address of the web instance"
  value       = aws_instance.web.public_ip
}
