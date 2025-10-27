variable "aws_region" {
  description = "The AWS region to deploy the infrastructure."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "The CIDR blocks for the subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "The availability zones to deploy the subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
