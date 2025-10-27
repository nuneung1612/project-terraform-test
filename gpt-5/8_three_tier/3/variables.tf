
# -----------------------------
# variables.tf
# -----------------------------
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "az1" {
  description = "Primary availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "az2" {
  description = "Secondary availability zone"
  type        = string
  default     = "us-east-1b"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "web_subnet_cidr_az1" {
  type    = string
  default = "10.0.1.0/24"
}

variable "web_subnet_cidr_az2" {
  type    = string
  default = "10.0.2.0/24"
}

variable "app_subnet_cidr_az1" {
  type    = string
  default = "10.0.3.0/24"
}

variable "app_subnet_cidr_az2" {
  type    = string
  default = "10.0.4.0/24"
}

variable "db_subnet_cidr_az1" {
  type    = string
  default = "10.0.5.0/24"
}

variable "db_subnet_cidr_az2" {
  type    = string
  default = "10.0.6.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for web/app tiers"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for Launch Templates"
  type        = string
  default     = "ami-052064a798f08f0d3"
}

variable "key_pair_name" {
  description = "Existing key pair name"
  type        = string
  default     = "3-tier-key-pair"
}

variable "asg_web_min" {
  type    = number
  default = 1
}
variable "asg_web_desired" {
  type    = number
  default = 2
}
variable "asg_web_max" {
  type    = number
  default = 4
}

variable "asg_app_min" {
  type    = number
  default = 1
}
variable "asg_app_desired" {
  type    = number
  default = 2
}
variable "asg_app_max" {
  type    = number
  default = 4
}

variable "db_name" {
  type    = string
  default = "mydb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}
