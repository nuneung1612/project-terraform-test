variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR block"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Public subnet CIDR block"
}

variable "private_subnet_cidr" {
  type        = string
  default     = "10.0.2.0/24"
  description = "Private subnet CIDR block"
}

variable "availability_zone" {
  type        = string
  default     = "us-east-1a"
  description = "Availability Zone"
}

variable "ami_id" {
  type        = string
  default     = "ami-052064a798f08f0d3"
  description = "AMI ID"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance Type"
}

variable "ssh_key_name" {
  type        = string
  default     = "vockey"
  description = "SSH Key Name"
}

variable "public_sg_name" {
  type        = string
  default     = "public-sg"
  description = "Public Security Group Name"
}

variable "private_sg_name" {
  type        = string
  default     = "private-sg"
  description = "Private Security Group Name"
}

variable "public_route_table_name" {
  type        = string
  default     = "public-route-table"
  description = "Public Route Table Name"
}

variable "private_route_table_name" {
  type        = string
  default     = "private-route-table"
  description = "Private Route Table Name"
}

variable "nat_gateway_eip" {
  type        = string
  default     = ""
  description = "NAT Gateway Elastic IP"
}

variable "bastion_instance_name" {
  type        = string
  default     = "bastion-jump-server"
  description = "Bastion Instance Name"
}

variable "private_instance_name" {
  type        = string
  default     = "private-instance"
  description = "Private Instance Name"
}
