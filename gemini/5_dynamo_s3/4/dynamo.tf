# This file defines the DynamoDB table used for Terraform state locking.
# State locking prevents concurrent runs of Terraform from corrupting the state file.
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "mycomponents_tf_lockid_2"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S" # S for String
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}
