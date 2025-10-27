resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = var.db_subnet_group_name
  }
}

resource "aws_db_instance" "main" {
  identifier             = "two-tier-rds-instance"
  instance_class         = var.db_instance_class
  allocated_storage      = var.allocated_storage
  engine                 = var.db_engine
  engine_version         = var.db_version
  master_username        = var.master_username
  master_password        = var.master_password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.private.id]

  tags = {
    Name = "main-rds-instance"
  }
}
