variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR block"
}

variable "public_1_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Public subnet 1 CIDR block"
}

variable "public_2_cidr" {
  type        = string
  default     = "10.0.2.0/24"
  description = "Public subnet 2 CIDR block"
}

variable "private_1_cidr" {
  type        = string
  default     = "10.0.3.0/24"
  description = "Private subnet 1 CIDR block"
}

variable "private_2_cidr" {
  type        = string
  default     = "10.0.4.0/24"
  description = "Private subnet 2 CIDR block"
}

variable "public_1_az" {
  type        = string
  default     = "us-east-1a"
  description = "Public subnet 1 availability zone"
}

variable "public_2_az" {
  type        = string
  default     = "us-east-1b"
  description = "Public subnet 2 availability zone"
}

variable "private_1_az" {
  type        = string
  default     = "us-east-1a"
  description = "Private subnet 1 availability zone"
}

variable "private_2_az" {
  type        = string
  default     = "us-east-1b"
  description = "Private subnet 2 availability zone"
}

variable "ami" {
  type        = string
  default     = "ami-0360c520857e3138f"
  description = "EC2 instance AMI"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  default     = "2-tier-key-pair"
  description = "EC2 instance key name"
}

variable "engine" {
  type        = string
  default     = "mysql"
  description = "RDS instance engine"
}

variable "engine_version" {
  type        = string
  default     = "8.0.39"
  description = "RDS instance engine version"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class"
}

variable "username" {
  type        = string
  description = "RDS instance username"
  sensitive   = true
}

variable "password" {
  type        = string
  description = "RDS instance password"
  sensitive   = true
}

variable "db_name" {
  type        = string
  default     = "twotierdatabase"
  description = "RDS instance database name"
}
