variable "aws-region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc-cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "web-subnet-cidrs" {
  description = "Web tier subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app-subnet-cidrs" {
  description = "App tier subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db-subnet-cidrs" {
  description = "DB tier subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability-zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
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
  description = "EC2 key pair name"
  type        = string
  default     = "3-tier-key-pair"
}

variable "db-username" {
  description = "RDS database username"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "db-password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

variable "db-name" {
  description = "RDS database name"
  type        = string
  default     = "mydb"
}

variable "db-instance-class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db-allocated-storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 10
}