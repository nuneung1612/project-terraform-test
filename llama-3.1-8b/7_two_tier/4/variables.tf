variable "ami" {
  type      = string
  default   = "ami-0360c520857e3138f"
  sensitive = false
}

variable "instance_type" {
  type      = string
  default   = "t2.micro"
  sensitive = false
}

variable "key_name" {
  type      = string
  default   = "2-tier-key-pair"
  sensitive = false
}

variable "engine" {
  type      = string
  default   = "mysql"
  sensitive = false
}

variable "engine_version" {
  type      = string
  default   = "8.0.39"
  sensitive = false
}

variable "instance_class" {
  type      = string
  default   = "db.t3.micro"
  sensitive = false
}

variable "db_name" {
  type      = string
  default   = "twotierdatabase"
  sensitive = false
}

variable "username" {
  type      = string
  default   = "twotieruser"
  sensitive = true
}

variable "password" {
  type      = string
  default   = "Tw0tierP@ssw0rd"
  sensitive = true
}

variable "vpc_cidr" {
  type      = string
  default   = "10.0.0.0/16"
  sensitive = false
}

variable "public_1_cidr" {
  type      = string
  default   = "10.0.1.0/24"
  sensitive = false
}

variable "public_2_cidr" {
  type      = string
  default   = "10.0.2.0/24"
  sensitive = false
}

variable "private_1_cidr" {
  type      = string
  default   = "10.0.3.0/24"
  sensitive = false
}

variable "private_2_cidr" {
  type      = string
  default   = "10.0.4.0/24"
  sensitive = false
}

variable "web1_az" {
  type      = string
  default   = "us-east-1a"
  sensitive = false
}

variable "web2_az" {
  type      = string
  default   = "us-east-1b"
  sensitive = false
}
