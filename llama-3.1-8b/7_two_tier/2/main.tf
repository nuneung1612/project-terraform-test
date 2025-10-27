terraform {
  required_version = ">= 1.0.0"

  backend "local" {}
}

provider "aws" {
  alias  = "east"
  region = "us-east-1"

  version = "~> 5.0"
}

module "network" {
  source = file("./network.tf")
}

module "security" {
  source = file("./security.tf")
}

module "alb" {
  source     = file("./alb.tf")
  depends_on = [module.network]
}

module "ec2" {
  source     = file("./ec2.tf")
  depends_on = [module.security]
}

module "database" {
  source     = file("./database.tf")
  depends_on = [module.security]
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.db_instance.endpoint
}
