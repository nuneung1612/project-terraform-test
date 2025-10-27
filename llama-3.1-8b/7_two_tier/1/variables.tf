variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
  description = "CIDR blocks for private subnets"
}

# Availability Zones
variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "Availability zones for the VPC"
}

# EC2 Instance Variables
variable "ami_id" {
  type        = string
  default     = "ami-0360c520857e3138f"
  description = "AMI ID for EC2 instances"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type for EC2 instances"
}

variable "key_pair_name" {
  type        = string
  description = "Name of the key pair for EC2 instances"
}

# RDS Instance Variables
variable "database_engine" {
  type        = string
  default     = "mysql"
  description = "Database engine for RDS instance"
}

variable "database_version" {
  type        = string
  default     = "8.0.39"
  description = "Database version for RDS instance"
}

variable "allocated_storage" {
  type        = number
  default     = 5
  description = "Allocated storage for RDS instance"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Instance class for RDS instance"
}

variable "database_name" {
  type        = string
  description = "Name of the database for RDS instance"
}

variable "master_username" {
  type        = string
  sensitive   = true
  description = "Username for RDS instance"
}

variable "master_password" {
  type        = string
  sensitive   = true
  description = "Password for RDS instance"
}

# Load Balancer Variables
variable "alb_type" {
  type        = string
  default     = "application"
  description = "Type of the load balancer"
}
