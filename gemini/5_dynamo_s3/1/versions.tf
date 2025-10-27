terraform {
  # Specifies the required Terraform version.
  required_version = ">= 1.0.0"

  # Configures the required providers, in this case, the AWS provider.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configures the S3 backend for remote state management.
  # This setup ensures that the state file is stored securely and centrally.
  # backend "s3" {
  #   bucket         = "josephy-1212312121"
  #   key            = "terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "mycomponents_tf_lockid_2"
  #   encrypt        = true
  # }
}

# Configures the AWS provider details.
provider "aws" {
  region = "us-east-1"
}
