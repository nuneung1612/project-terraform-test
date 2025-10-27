terraform {
  #   backend "s3" {
  #     bucket         = "josephy-1212312121"
  #     key            = "terraform.tfstate"
  #     region         = "us-east-1"
  #     dynamodb_table = "mycomponents_tf_lockid_2"
  #     encrypt        = true
  #   }
}

# Variables
variable "region" {
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for backend storage"
  default     = "josephy-1212312121"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for state locking"
  default     = "mycomponents_tf_lockid_2"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# S3 Bucket for Backend Storage
resource "aws_s3_bucket" "backend_bucket" {
  bucket = var.bucket_name
  acl    = "private"
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "Backend_Bucket"
  }
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "dynamodb_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "State_Locking_Table"
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block                = var.vpc_cidr_block
  default_network_acl_id    = aws_network_acl.main.id
  default_route_table_id    = aws_route_table.main.id
  default_security_group_id = aws_security_group.main.id

  tags = {
    Name = "main"
  }
}

# Network ACL
resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}

# Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}

# Security Group
resource "aws_security_group" "main" {
  name   = "main"
  vpc_id = aws_vpc.main.id
}

# Ingress Rule for Security Group
resource "aws_security_group_rule" "ingress_rule" {
  type              = "ingress"
  security_group_id = aws_security_group.main.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Egress Rule for Security Group
resource "aws_security_group_rule" "egress_rule" {
  type              = "egress"
  security_group_id = aws_security_group.main.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
