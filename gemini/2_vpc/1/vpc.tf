# AWS VPC Resource
resource "aws_vpc" "main" {
  # 1. The VPC name is main (This is for the resource name in Terraform state)
  # 2. The CIDR block is 10.0.0.0/16
  cidr_block = "10.0.0.0/16"

  # 3. The instance tenancy is set to default
  instance_tenancy = "default"

  # Optional: Enable DNS support and hostnames for the VPC
  enable_dns_support   = true
  enable_dns_hostnames = true

  # 4. The tag Name should be set to main
  tags = {
    Name = "main"
  }
}