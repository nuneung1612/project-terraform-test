resource "aws_dynamodb_table" "state_lock" {
  name         = "mycomponents_tf_lockid_2"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "State_Lock"
  }
}
