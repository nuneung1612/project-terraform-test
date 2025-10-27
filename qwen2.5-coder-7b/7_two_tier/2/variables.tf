variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_public_1_cidr_block" {
  description = "CIDR block for the first public subnet"
  default     = "10.0.1.0/24"
}

variable "subnet_public_2_cidr_block" {
  description = "CIDR block for the second public subnet"
  default     = "10.0.2.0/24"
}

variable "subnet_private_1_cidr_block" {
  description = "CIDR block for the first private subnet"
  default     = "10.0.3.0/24"
}

variable "subnet_private_2_cidr_block" {
  description = "CIDR block for the second private subnet"
  default     = "10.0.4.0/24"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  default     = "ami-0360c520857e3138f"
}

variable "instance_type_ec2" {
  description = "Instance type for the EC2 instances"
  default     = "t2.micro"
}

variable "instance_type_rds" {
  description = "Instance type for the RDS instance"
  default     = "db.t3.micro"
}

variable "key_pair_name" {
  description = "Name of the key pair for SSH access"
  default     = "2-tier-key-pair"
}

variable "master_username" {
  description = "Master username for the RDS database"
  default     = "admin"
}

variable "master_password" {
  description = "Master password for the RDS database"
  sensitive   = true
  default     = "admin12345678"
}

variable "db_engine" {
  description = "Database engine for RDS"
  default     = "mysql"
}

variable "db_version" {
  description = "Database version for RDS"
  default     = "8.0.39"
}

variable "db_subnet_group_name" {
  description = "Name for the DB subnet group"
  default     = "two-tier-db-subnet-group"
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance"
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage for the RDS instance"
  default     = 5
}

variable "database_name" {
  description = "Name of the database"
  default     = "twotierdatabase"
}
