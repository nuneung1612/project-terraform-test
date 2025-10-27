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
  description = "The CIDR blocks for the web tier subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app-subnet-cidrs" {
  description = "The CIDR blocks for the application tier subnets."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db-subnet-cidrs" {
  description = "The CIDR blocks for the database tier subnets."
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "ami-id" {
  description = "The ID of the AMI to use for the EC2 instances."
  type        = string
  default     = "ami-052064a798f08f0d3"
}

variable "instance-type" {
  description = "The instance type to use for the EC2 instances."
  type        = string
  default     = "t2.micro"
}

variable "key-name" {
  description = "The name of the key pair to use for the EC2 instances."
  type        = string
  default     = "3-tier-key-pair"
}

variable "db-name" {
  description = "The name of the RDS database."
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
