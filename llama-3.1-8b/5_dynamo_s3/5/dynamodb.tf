terraform {
  required_version = ">= 1.0.0"
}

resource "aws_dynamodb_table" "tf_lockid" {
  name         = "mycomponents_tf_lockid_2"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}
