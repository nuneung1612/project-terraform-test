# This block configures the S3 backend for remote state storage.
# Note: Before this configuration can be used, the corresponding S3 bucket
# and DynamoDB table must be created. You can comment out this block,
# run 'terraform apply' to create the resources, then uncomment this block
# and run 'terraform init -reconfigure' to migrate the state.

# terraform {
#   backend "s3" {
#     bucket         = "josephy-1212312121"
#     key            = "terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "mycomponents_tf_lockid_2"
#   }
# }
