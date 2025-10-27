locals {
  vpc_cidr_block = "10.0.0.0/16"
  subnets_web    = ["10.0.1.0/24", "10.0.2.0/24"]
  subnets_app    = ["10.0.3.0/24", "10.0.4.0/24"]
  subnets_db     = ["10.0.5.0/24", "10.0.6.0/24"]
  azs          = ["us-east-1a", "us-east-1b"]
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  default     = "3-tier-key-pair"
}

variable "ami_id" {
  description = "The Amazon Machine Image ID to use for the instances"
  default     = "ami-052064a798f08f0d3"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}
