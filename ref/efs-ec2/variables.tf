# variable "public_key" {
#   type        = string
#   description = "File path of public key."
#   default     = "~/.ssh/id_rsa.pub"
# }

variable "private_key" {
  type        = string
  description = "File path of private key."
  default     = "C:/Users/USER/Downloads/ec2-key.pem"
}

variable "key_name" {
    type = string
    description = "Key name"
    default = "ec2-key"
  
}

variable "ami_id" {
    type = string
    description = "ami id for ec2 instances"
    default = "ami-0341d95f75f311023"
  
}

variable "instance_type" {
    type = string
    description = "ec2 instance type"
    default = "t2.micro"
  
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
  
}

variable "user_data_file" {
  type = string
  default = "user-data.sh"
}