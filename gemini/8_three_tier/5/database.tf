resource "aws_db_instance" "default" {
  identifier           = "three-tier-rds-mysql"
  allocated_storage    = var.db-allocated-storage
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.db-instance-class
  db_name              = var.db-name
  username             = var.db-username
  password             = var.db-password
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db.id]
  multi_az             = true
  skip_final_snapshot  = true

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-rds-mysql"
    }
  )
}
