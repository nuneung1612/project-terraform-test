# Configures the AWS provider and defines the S3 backend for remote state storage.
# Note: To initially create the backend resources (S3 bucket, DynamoDB table),
# you should comment out the `backend "s3"` block, run `terraform apply`,
# and then uncomment it to migrate the state.

provider "aws" {
  region = var.aws_region
}

terraform {
  # backend "s3" {
  #   bucket         = "josephy-1212312121"
  #   key            = "terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "mycomponents_tf_lockid_2"
  #   encrypt        = true
  # }
}
