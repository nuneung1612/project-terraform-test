variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Public subnet CIDR block"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "Private subnet CIDR block"
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone"
  default     = "us-east-1a"
}

variable "ami_id" {
  type        = string
  description = "AMI ID"
  default     = "ami-052064a798f08f0d3"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
  default     = "t2.micro"
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key name"
  default     = "vockey"
}

variable "public_sg_name" {
  type        = string
  description = "Public security group name"
  default     = "public-sg"
}

variable "private_sg_name" {
  type        = string
  description = "Private security group name"
  default     = "private-sg"
}

variable "public_sg_description" {
  type        = string
  description = "Public security group description"
  default     = "Public security group for bastion host"
}

variable "private_sg_description" {
  type        = string
  description = "Private security group description"
  default     = "Private security group for private instance"
}

variable "public_route_table_name" {
  type        = string
  description = "Public route table name"
  default     = "public-route-table"
}

variable "private_route_table_name" {
  type        = string
  description = "Private route table name"
  default     = "private-route-table"
}

variable "nat_gateway_eip_allocation_id" {
  type        = string
  description = "NAT Gateway Elastic IP allocation ID"
  default     = ""
}

variable "bastion_instance_name" {
  type        = string
  description = "Bastion instance name"
  default     = "bastion-host"
}

variable "private_instance_name" {
  type        = string
  description = "Private instance name"
  default     = "private-instance"
}

variable "bastion_tags" {
  type        = map(string)
  description = "Bastion instance tags"
  default     = {
    Name        = "Bastion Host"
    Environment = "Development"
  }
}

variable "private_tags" {
  type        = map(string)
  description = "Private instance tags"
  default     = {
    Name        = "Private Instance"
    Environment = "Development"
  }
}

variable "public_tags" {
  type        = map(string)
  description = "Public route table tags"
  default     = {
    Name        = "Public Route Table"
    Environment = "Development"
  }
}

variable "private_tags" {
  type        = map(string)
  description = "Private route table tags"
  default     = {
    Name        = "Private Route Table"
    Environment = = "Development"
  }
}
