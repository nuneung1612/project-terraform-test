provider "aws" {
  region = var.region
}

module "network" {
  source = file("./network")
}

module "security" {
  source = file("./security")
}

module "compute" {
  source = file("./compute")
}

