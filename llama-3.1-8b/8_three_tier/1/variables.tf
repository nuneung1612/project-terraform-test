variable "db-username" {
  type        = string
  description = "Database username"
  sensitive   = true
}

variable "db-password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "key-pair-name" {
  type        = string
  description = "Key pair name"
}

variable "ami-id" {
  type        = string
  description = "AMI ID"
  default     = "ami-052064a798f08f0d3"
}

variable "db-name" {
  type        = string
  description = "Database name"
  default     = "mydb"
}
