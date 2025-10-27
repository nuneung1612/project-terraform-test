variable "aws-region" {
  description = "The AWS region to deploy the infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "vpc-cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "web-subnet-cidrs" {
  description = "The CIDR blocks for the public web subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app-subnet-cidrs" {
  description = "The CIDR blocks for the private application subnets."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db-subnet-cidrs" {
  description = "The CIDR blocks for the private database subnets."
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability-zones" {
  description = "The availability zones to use for the subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ami-id" {
  description = "The AMI ID for the EC2 instances (Amazon Linux 2)."
  type        = string
  default     = "ami-052064a798f08f0d3"
}

variable "key-pair-name" {
  description = "The name of the key pair to use for EC2 instances."
  type        = string
  default     = "3-tier-key-pair"
}

variable "db-name" {
  description = "The name of the database to create in the RDS instance."
  type        = string
  default     = "mydb"
}

variable "db-username" {
  description = "The username for the RDS database."
  type        = string
  sensitive   = true
}

variable "db-password" {
  description = "The password for the RDS database."
  type        = string
  sensitive   = true
}
