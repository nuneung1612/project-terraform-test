########################################
# providers.tf
########################################
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = "terraform-backend-and-vpc"
    }
  }
}
