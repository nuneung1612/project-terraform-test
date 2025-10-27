terraform {
  required_version = ">= 1.0.0"

  backend "local" {
    path = "./state"
  }
}

provider "aws" {
  region  = "us-east-1"
  version = ">= 5.0.0"
}
