// variables.tf

variable "project" {
  description = "Project tag"
  type        = string
  default     = "two-tier-app"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# VPC & Subnets
variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to use (must be two distinct AZs)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for the public subnets in the specified AZs order"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for the private subnets in the specified AZs order"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# Compute
variable "ami_id" {
  description = "AMI ID for web instances"
  type        = string
  default     = "ami-0360c520857e3138f"
}

variable "ec2_instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Existing key pair name to use for SSH"
  type        = string
  default     = "2-tier-key-pair"
}

# Database
variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  # MySQL 8.0.39 per requirement
  default     = "8.0.39"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GiB (gp3 minimum commonly >= 20)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "twotierdatabase"
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Master password"
  type        = string
  default     = "admin12345678"
  sensitive   = true
}
