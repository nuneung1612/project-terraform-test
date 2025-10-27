provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"
}

# Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_1" {
  description = "CIDR block for the first public subnet"
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr_2" {
  description = "CIDR block for the second public subnet"
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr_1" {
  description = "CIDR block for the first private subnet"
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr_2" {
  description = "CIDR block for the second private subnet"
  default     = "10.0.4.0/24"
}

variable "web1_az" {
  description = "Availability zone for web1 instance"
  default     = "us-east-1a"
}

variable "web2_az" {
  description = "Availability zone for web2 instance"
  default     = "us-east-1b"
}

variable "ami" {
  description = "AMI ID for EC2 instances"
  default     = "ami-0360c520857e3138f"
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key name for EC2 instances"
  default     = "2-tier-key-pair"
}

variable "db_engine" {
  description = "Database engine for RDS instance"
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version for RDS instance"
  default     = "8.0.39"
}

variable "db_instance_class" {
  description = "Instance class for RDS instance"
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name for RDS instance"
  default     = "twotierdatabase"
}

variable "db_username" {
  description = "Database username for RDS instance"
  sensitive   = true
}

variable "db_password" {
  description = "Database password for RDS instance"
  sensitive   = true
}
