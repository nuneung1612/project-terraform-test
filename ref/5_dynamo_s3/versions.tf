terraform {
  # backend "s3" {
  #   bucket         = "josephy-1212312121"
  #   key            = "terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "mycomponents_tf_lockid_2"
  # }

  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}
provider "aws" {
  region     = "us-west-2"

}
