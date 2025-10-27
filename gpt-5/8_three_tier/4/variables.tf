# ===================================================================
# variables.tf
# ===================================================================
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# NOTE: Terraform variable identifiers cannot use hyphens; use underscores here.
# Marked sensitive per requirement.
variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

# Kebab-case preferences captured within a single config object using quoted keys
variable "config" {
  description = "General configuration (keys use kebab-case by requirement)"
  type = object({
    "project-prefix" = string
    "key-pair-name"  = string
    "ami-id"         = string
  })
  default = {
    "project-prefix" = "three-tier"
    "key-pair-name"  = "3-tier-key-pair"
    "ami-id"         = "ami-052064a798f08f0d3"
  }
}
