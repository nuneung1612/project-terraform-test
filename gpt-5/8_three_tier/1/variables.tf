# variables.tf
variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

# Network
variable "vpc_cidr" {
  description = "CIDR for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used for subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "web_subnet_cidrs" {
  description = "Public web subnets CIDRs."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_subnet_cidrs" {
  description = "Private app subnets CIDRs."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db_subnet_cidrs" {
  description = "Private DB subnets CIDRs."
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

# Compute
variable "ami_id" {
  description = "AMI ID for EC2 instances (Amazon Linux 2)."
  type        = string
  default     = "ami-052064a798f08f0d3"
}

variable "key_pair_name" {
  description = "EC2 key pair name."
  type        = string
  default     = "3-tier-key-pair"
}

variable "web_instance_type" {
  description = "Instance type for web tier."
  type        = string
  default     = "t2.micro"
}

variable "app_instance_type" {
  description = "Instance type for app tier."
  type        = string
  default     = "t2.micro"
}

# Database
variable "db_username" {
  description = "Master username for RDS."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for RDS."
  type        = string
  sensitive   = true
}
