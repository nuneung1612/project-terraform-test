variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "Public subnet CIDR blocks"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidr" {
  type        = list(string)
  description = "Private subnet CIDR blocks"
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "nat_gateway_count" {
  type        = number
  description = "Number of NAT gateways"
  default     = 2
}

variable "instance_tenancy" {
  type        = string
  description = "Instance tenancy"
  default     = "default"
}
