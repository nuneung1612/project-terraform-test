# variables.tf
variable "aws-region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc-cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability-zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "web-subnet-cidrs" {
  description = "CIDR blocks for web tier subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app-subnet-cidrs" {
  description = "CIDR blocks for app tier subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db-subnet-cidrs" {
  description = "CIDR blocks for database tier subnets"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "ami-id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-052064a798f08f0d3"
}

variable "instance-type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key-pair-name" {
  description = "Key pair name for EC2 instances"
  type        = string
  default     = "3-tier-key-pair"
}

variable "db-instance-class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db-name" {
  description = "Database name"
  type        = string
  default     = "mydb"
}

variable "db-username" {
  description = "Database master username"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "db-password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db-allocated-storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 10
}