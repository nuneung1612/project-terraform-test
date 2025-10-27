# This resource creates the main VPC for the infrastructure.

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"

  tags = {
    Name = "main"
  }
}
