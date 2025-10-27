variable "vpc-cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "public1-subnet-cidr" {
  type = string
  default = "10.0.1.0/24"
}

variable "public2-subnet-cidr" {
  type = string
  default = "10.0.2.0/24"
}

variable "private1-subnet-cidr" {
    type = string
    default = "10.0.3.0/24"
  
}
variable "private2-subnet-cidr" {
    type = string
    default = "10.0.4.0/24"
  
}

variable "web1-az" {
  type = string
  default = "us-east-1a"
}

variable "web2-az" {
  type = string
  default = "us-east-1b"
}

variable "ami" {
  type = string
  default = "ami-0360c520857e3138f"
}

variable "key-name" {
  type = string
  default = "2-tier-key-pair"
}

variable "instance-type" {
    type = string
    default = "t2.micro"
  
}

variable "db-instance-type" {
    type = string
    default = "db.t3.micro"
  
}

variable "db-name"{
    type = string
    default = "twotierdatabase"
}

variable "db-username" {
    type = string
    default = "admin"
    sensitive = true
  
}
variable "db-password" {
    type = string
    default = "admin12345678"
    sensitive = true
  
}
variable "db-engine" {
    type = string
    default = "mysql"
  
}
variable "db-engine-version"{
    type = string
    default = "8.0.39"
}