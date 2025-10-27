terraform {
  required_version = ">= 1.0.0"

  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "aws" {
  version = ">= 5.0.0"

  region = "us-east-1"
}
