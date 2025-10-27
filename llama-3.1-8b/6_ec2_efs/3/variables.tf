variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_id" {
  type    = string
  default = "ami-0341d95f75f311023"
}

variable "project_name" {
  type    = string
  default = "example-project"
}

variable "efs_mount_point" {
  type    = string
  default = "/mnt/efs"
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "key_name" {
  type = string
}
