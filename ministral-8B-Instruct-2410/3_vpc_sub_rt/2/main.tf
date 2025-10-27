provider "aws" {
  version    = "~> 5.0"
  region     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for public subnets"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for private subnets"
  type        = string
  default     = "10.0.10.0/24"
}
