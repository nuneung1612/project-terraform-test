variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name_tag" {
  description = "Name tag for the VPC"
  type        = string
  default     = "main-vpc"
}
