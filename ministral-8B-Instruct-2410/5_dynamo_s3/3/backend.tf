terraform {
#   backend "s3" {
#     bucket         = "josephy-1212312121"
#     key            = "terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "mycomponents_tf_lockid_2"
#   }
}

provider "aws" {
  region = "us-east-1"
}
