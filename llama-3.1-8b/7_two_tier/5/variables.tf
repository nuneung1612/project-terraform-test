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

variable "web1_az" {
  type        = string
  default     = "us-east-1a"
  description = "Availability zone for web1 instance"
}

variable "web2_az" {
  type        = string
  default     = "us-east-1b"
  description = "Availability zone for web2 instance"
}

variable "ami" {
  type        = string
  default     = "ami-0360c520857e3138f"
  description = "AMI ID"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type"
}

variable "key_name" {
  type        = string
  default     = "2-tier-key-pair"
  description = "Key pair name"
}

variable "engine" {
  type        = string
  default     = "mysql"
  description = "Database engine"
}

variable "engine_version" {
  type        = string
  default     = "8.0.39"
  description = "Database engine version"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Instance class"
}

variable "db_name" {
  type        = string
  default     = "twotierdatabase"
  description = "Database name"
}

variable "username" {
  type        = string
  sensitive   = true
  description = "Database username"
}

variable "password" {
  type        = string
  sensitive   = true
  description = "Database password"
}
