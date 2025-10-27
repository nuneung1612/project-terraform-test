# This file defines the main VPC for the infrastructure.

resource "aws_vpc" "main" {
  # The primary CIDR block for the VPC.
  cidr_block = "10.0.0.0/16"

  # Specifies whether instances launched in this VPC will be dedicated or shared.
  instance_tenancy = "default"

  # A descriptive name tag for easy identification of the VPC in the AWS console.
  tags = {
    Name = "main"
  }
}
