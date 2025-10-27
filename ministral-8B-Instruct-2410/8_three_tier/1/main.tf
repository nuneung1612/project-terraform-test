terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}

module "network" {
  source = "./modules/network"
}

module "web_tier" {
  source = "./modules/web_tier"
  vpc_id           = module.network.vpc_id
  public_subnets    = module.network.public_subnets
  private_subnets   = module.network.private_subnets
  security_group_alb = module.web_tier.security_group_alb
  security_group_instances = module.web_tier.security_group_instances
  albs = {
    "web-alb" = module.web_tier.alb
  }
}

module "app_tier" {
  source = "./modules/app_tier"
  vpc_id           = module.network.vpc_id
  public_subnets    = module.network.public_subnets
  private_subnets   = module.network.private_subnets
  security_group_alb = module.app_tier.security_group_alb
  security_group_instances = module.app_tier.security_group_instances
  albs = {
    "app-alb" = module.app_tier.alb
  }
}

module "db_tier" {
  source = "./modules/db_tier"
  vpc_id           = module.network.vpc_id
  private_subnets   = module.network.private_subnets
  security_group_db = module.db_tier.security_group_db
  db_subnet_group  = module.db_tier.db_subnet_group
}
