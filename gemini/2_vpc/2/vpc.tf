# Creates the main Virtual Private Cloud (VPC).
resource "aws_vpc" "main" {
  # The IPv4 CIDR block for the VPC.
  cidr_block = "10.0.0.0/16"

  # A tenancy option for instances launched into the VPC.
  # "default" means instances use shared hardware.
  instance_tenancy = "default"

  # Tags are key-value pairs that help you manage, identify, organize, search for, and filter resources.
  tags = {
    Name = "main"
  }
}

