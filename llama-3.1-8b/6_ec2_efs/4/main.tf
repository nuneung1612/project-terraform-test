terraform {
  required_version = ">= 1.0"
}

variable "efs_id" {
  type        = string
  sensitive   = true
  description = "EFS ID"
}

variable "efs_mount_target_ip" {
  type        = string
  sensitive   = true
  description = "EFS mount target IP address"
}

provider "aws" {
  region  = var.aws_region
  version = "~> 5.0"
}
