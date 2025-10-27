# Define the DynamoDB table
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "mycomponents_tf_lockid_2"
  billing_mode = "PAY_PER_REQUEST"

  # Define table attributes
  attribute {
    name = "LockID"
    type = "S"
  }
}
