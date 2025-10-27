# This block configures Terraform to use an S3 bucket for storing its state file.
# The S3 bucket and DynamoDB table for locking must be created before you can initialize this backend.
# You can bootstrap them by commenting out this block, running `terraform apply`,
# and then uncommenting it for subsequent runs.
terraform {
  # backend "s3" {
  #   bucket         = "josephy-1212312121"
  #   key            = "terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "mycomponents_tf_lockid_2"
  # }
}
