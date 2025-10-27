resource "aws_availability_zone" "zone" {
  count = 2
  name = var.availability_zones[aws_region.current.name]
}
