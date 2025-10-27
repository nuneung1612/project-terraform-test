# This resource creates the DynamoDB table used for Terraform state locking.
# State locking prevents multiple users from running Terraform at the same time,
# which can corrupt the state.

resource "aws_dynamodb_table" "tf_lock" {
  name           = "mycomponents_tf_lockid_2"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "terraform-lock-table"
  }
}
