############################
# locals.tf
############################
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "zone-name"
    values = ["us-east-1a", "us-east-1b"]
  }
}

locals {
  azs = ["us-east-1a", "us-east-1b"]

  vpc_cidr = "10.0.0.0/16"

  subnets = {
    web = {
      a = { cidr = "10.0.1.0/24", az = local.azs[0], public = true }
      b = { cidr = "10.0.2.0/24", az = local.azs[1], public = true }
    }
    app = {
      a = { cidr = "10.0.3.0/24", az = local.azs[0], public = false }
      b = { cidr = "10.0.4.0/24", az = local.azs[1], public = false }
    }
    db = {
      a = { cidr = "10.0.5.0/24", az = local.azs[0], public = false }
      b = { cidr = "10.0.6.0/24", az = local.azs[1], public = false }
    }
  }
}
