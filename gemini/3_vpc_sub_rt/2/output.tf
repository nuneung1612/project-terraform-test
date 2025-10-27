# Outputs the ID of the created VPC.
output "vpc_id" {
  description = "The ID of the main VPC."
  value       = aws_vpc.main.id
}

# Outputs a list of IDs for the created public subnets.
output "public_subnet_ids" {
  description = "A list of the public subnet IDs."
  value       = aws_subnet.public[*].id
}

# Outputs a list of IDs for the created private subnets.
output "private_subnet_ids" {
  description = "A list of the private subnet IDs."
  value       = aws_subnet.private[*].id
}

# Outputs the ID of the Internet Gateway.
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.main.id
}

# Outputs a list of IDs for the NAT Gateways.
output "nat_gateway_ids" {
  description = "A list of the NAT Gateway IDs."
  value       = aws_nat_gateway.main[*].id
}
