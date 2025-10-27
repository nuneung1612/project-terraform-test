variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "The availability zones for the subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances."
  type        = string
  default     = "ami-0360c520857e3138f" # Amazon Linux 2023 - us-east-1
}

variable "ec2_instance_type" {
  description = "The instance type for the EC2 instances."
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "The name of the key pair for SSH access to the EC2 instances."
  type        = string
  default     = "2-tier-key-pair"
}

variable "db_instance_class" {
  description = "The instance class for the RDS database."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the RDS database."
  type        = string
  default     = "twotierdatabase"
}

variable "db_username" {
  description = "The master username for the RDS database."
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "The master password for the RDS database."
  type        = string
  default     = "admin12345678"
  sensitive   = true
}

variable "db_engine" {
  description = "The database engine for the RDS instance."
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "The database engine version for the RDS instance."
  type        = string
  default     = "8.0.39"
}