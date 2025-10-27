provider "aws" {
  region  = "us-east-1"
  version = "~> 5.0"
}
variable "web1_az" {
  default = "us-east-1a"
}

variable "web2_az" {
  default = "us-east-1b"
}

variable "public_cidr_1" {
  default = "10.0.1.0/24"
}

variable "public_cidr_2" {
  default = "10.0.2.0/24"
}

variable "private_cidr_1" {
  default = "10.0.3.0/24"
}

variable "private_cidr_2" {
  default = "10.0.4.0/24"
}

variable "ami" {
  default = "ami-0360c520857e3138f"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "2-tier-key-pair"
}

variable "db_engine" {
  default = "mysql"
}

variable "db_engine_version" {
  default = "8.0.39"
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_name" {
  default = "twotierdatabase"
}

variable "db_username" {
  sensitive = true
}

variable "db_password" {
  sensitive = true
}
