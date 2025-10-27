variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "key_pair_name" {
  type        = string
  description = "Name of the key pair"
  sensitive   = false
}

variable "ami_id" {
  type        = string
  description = "AMI ID"
  sensitive   = false
}

variable "db_username" {
  type        = string
  description = "Database username"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "db_instance_class" {
  type        = string
  description = "Database instance class"
  default     = "db.t3.micro"
}

variable "db_storage" {
  type        = number
  description = "Database storage"
  default     = 10
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "web_subnet_cidrs" {
  type        = list(string)
  description = "Web subnet CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_subnet_cidrs" {
  type        = list(string)
  description = "App subnet CIDRs"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db_subnet_cidrs" {
  type        = list(string)
  description = "DB subnet CIDRs"
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}
