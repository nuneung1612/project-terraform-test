variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for the instances"
  type        = string
  sensitive   = true
}

variable "ami_id" {
  description = "AMI ID to use for the instances"
  type        = string
  default     = "ami-0c94855ba95c71c99" # Example AMI ID for Amazon Linux 2 in us-east-1
}
