resource "aws_dynamodb_table" "new_table" {
  name         = "mycomponents_tf_lockid_2"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}
