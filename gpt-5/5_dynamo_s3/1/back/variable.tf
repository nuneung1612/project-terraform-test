# =========================================================
# 0_backend_bootstrap/variables.tf
# =========================================================
variable "aws_region" {
  description = "AWS region for bootstrap resources"
  type        = string
  default     = "us-east-1"
}
