terraform {
  required_version = ">= 1.0.0"

  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-lock-table"
  # }
}

provider "aws" {
  region  = "us-east-1"
  version = "~> 5.0"

  default_tags {
    tags = {
      Environment = "dev"
    }
  }
}
