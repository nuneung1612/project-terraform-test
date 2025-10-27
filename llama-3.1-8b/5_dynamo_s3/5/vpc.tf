terraform {
  required_version = ">= 1.0.0"
}

provider "aws" {
  region  = "us-east-1"
  version = "~> 5.0"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = {
    Name = "main"
  }
}
