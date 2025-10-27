variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR Block"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_subnet_az" {
  description = "Availability Zone for Public Subnet"
  type        = string
  default     = "us-east-1a"
}

variable "private_subnet_cidr" {
  description = "Private Subnet CIDR Block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_az" {
  description = "Availability Zone for Private Subnet"
  type        = string
  default     = "us-east-1a"
}

variable "ami" {
  description = "AMI ID"
  type        = string
  default     = "ami-052064a798f08f0d3"
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH Key Pair Name"
  type        = string
  default     = "vockey"
}
