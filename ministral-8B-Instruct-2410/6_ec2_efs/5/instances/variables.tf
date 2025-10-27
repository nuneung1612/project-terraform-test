variable "aws_region" {
  description = "The AWS region to deploy the infrastructure."
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances."
  type        = string
  default     = "ami-0341d95f75f311023"
}

variable "user_data" {
  description = "The user data script for the EC2 instances."
  type        = string
}

variable "efs_id" {
  description = "The ID of the EFS file system."
  type        = string
}

variable "efs_mount_point" {
  description = "The mount point for the EFS."
  type        = string
}

variable "instance_num" {
  description = "The number of EC2 instances."
  type        = number
  default     = 2
}
