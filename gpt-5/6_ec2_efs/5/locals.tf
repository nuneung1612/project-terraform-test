// locals.tf
locals {
  project_tags = {
    Project = var.project_name
    Managed = "terraform"
  }
}
