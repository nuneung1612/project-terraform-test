# variables.tf
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_1_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_2_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
  default     = "10.0.4.0/24"
}

variable "web1_az" {
  description = "Availability Zone for web1"
  type        = string
  default     = "us-east-1a"
}

variable "web2_az" {
  description = "Availability Zone for web2"
  type        = string
  default     = "us-east-1b"
}

variable "web_ami_id" {
  description = "AMI ID for web instances"
  type        = string
  default     = "ami-0360c520857e3138f"
}

variable "web_instance_type" {
  description = "Instance type for web servers"
  type        = string
  default     = "t2.micro"
}

variable "web_key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = "2-tier-key-pair"
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0.39"
}

variable "db_instance_class" {
  description = "DB instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "twotierdatabase"
}

variable "db_username" {
  description = "Master username for DB"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for DB"
  type        = string
  sensitive   = true
}
