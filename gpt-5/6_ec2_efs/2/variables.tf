# =========================================================
# variables.tf
# =========================================================
variable "project_name" {
  description = "Project name used for tagging."
  type        = string
  default     = "terraform-efs-web"
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (one per AZ)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
  description = "Availability Zones to use."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID."
  type        = string
  default     = "ami-0341d95f75f311023"
}

variable "efs_mount_point" {
  description = "Linux mount point for EFS."
  type        = string
  default     = "/mnt/efs"
}

variable "instance_count" {
  description = "Number of EC2 instances to deploy."
  type        = number
  default     = 2
}

variable "key_name" {
  description = "Optional EC2 Key Pair name for SSH access."
  type        = string
  default     = null
}
