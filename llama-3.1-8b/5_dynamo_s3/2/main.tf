terraform {
  required_version = ">= 1.0.0"

  # Define the AWS provider
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = " ~> 5.0"
    }
  }

  # Define the backend configuration
#   backend "s3" {
#     bucket         = "josephy-1212312121"
#     key            = "terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "mycomponents_tf_lockid_2"
#   }
}
