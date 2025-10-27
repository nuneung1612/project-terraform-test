# providers.tf
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = "three-tier"
      Managed = "terraform"
    }
  }
}
