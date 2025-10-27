terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws-region
}

# Creates a key pair to be used for SSH access to the instances.
# In a real-world scenario, you would likely manage the private key securely.
resource "aws_key_pair" "three_tier_key_pair" {
  key_name   = "3-tier-key-pair"
  public_key = "" # Example public key

  tags = {
    Name = "three-tier-key-pair"
  }
}
