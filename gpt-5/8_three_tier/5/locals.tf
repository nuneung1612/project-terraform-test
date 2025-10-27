// locals.tf
locals {
  name_prefix = "${var.prefix}-"
  common_tags = {
    Project = "${var.prefix}"
  }
}
