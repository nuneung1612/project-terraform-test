terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./vpc"
}

module "efs" {
  source = "./efs"
}

module "instances" {
  source = "./instances"
}

module "security_groups" {
  source = "./security_groups"
}
