# Note: To initialize this configuration for the first time, you must comment out this entire backend block.
# 1. Run `terraform init` and `terraform apply` with the backend block commented out to create the S3 bucket and DynamoDB table.
# 2. Uncomment this block.
# 3. Run `terraform init -reconfigure`. Terraform will prompt you to migrate your state to the new S3 backend.
#
# This two-step process is necessary because the backend resources must exist before Terraform can use them to store state.

# terraform {
#   backend "s3" {
#     bucket         = "josephy-1212312121"
#     key            = "terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "mycomponents_tf_lockid_2"
#     encrypt        = true
#   }
# }
