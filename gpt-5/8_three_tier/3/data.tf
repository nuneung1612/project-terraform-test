# -----------------------------
# data.tf
# -----------------------------
data "aws_key_pair" "existing" {
  key_name = var.key_pair_name
}