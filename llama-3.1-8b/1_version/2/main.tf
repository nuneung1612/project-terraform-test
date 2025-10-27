terraform {
  required_version = ">= 1.0.0"

  # Configure the AWS provider
  provider "aws" {
    version = ">= 5.0.0"
    region  = "us-east-1"
  }

  # Configure the backend for state file storage
  backend "local" {
    path = "./terraform.tfstate"
  }
}
