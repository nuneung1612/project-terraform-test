resource "aws_dynamodb_table" "tf_lock" {
  name         = "mycomponents_tf_lockid_2"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = local.common_tags
}
