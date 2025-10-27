variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region"
}

variable "key_pair_name" {
  type        = string
  default     = "3-tier-key-pair"
  description = "Existing Key Pair Name"
}

variable "ami_id" {
  type        = string
  default     = "ami-052064a798f08f0d3"
  description = "Amazon Linux 2 AMI ID"
}

variable "db_name" {
  type        = string
  default     = "mydb"
  description = "Database Name"
}

variable "db_username" {
  type        = string
  sensitive   = true
  description = "Database Username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database Password"
}

variable "web_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Web Subnet IDs"
}

variable "app_subnet_ids" {
  type        = list(string)
  default     = []
  description = "App Subnet IDs"
}

variable "db_subnet_ids" {
  type        = list(string)
  default     = []
  description = "DB Subnet IDs"
}
