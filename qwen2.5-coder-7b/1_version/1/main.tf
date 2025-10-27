terraform {
  required_version = ">= 1.0.0"
}

provider "aws" {
  version         = ">= 5.0"
  region          = "us-east-1"
}

backend "local" {}

variable "state_file_path" {
  description = "The path where the Terraform state file will be stored locally."
  default     = "./terraform.tfstate"
}
