// FILENAME: vpc.tf

# Retrieves the list of available Availability Zones in the configured region.
# This allows the infrastructure to adapt to any region without hardcoding AZ names.
data "aws_availability_zones" "available" {
  state = "available"
}

# The main Virtual Private Cloud (VPC) resource. This provides an isolated
# network environment for your AWS resources.
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}