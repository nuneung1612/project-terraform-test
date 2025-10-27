// rds.tf
resource "aws_db_subnet_group" "db" {
  name       = "${local.name_prefix}db-subnet-group"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_b.id]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}db-subnet-group"
  })
}

resource "aws_db_instance" "mysql" {
  identifier                      = "${local.name_prefix}rds-mysql"
  engine                          = "mysql"
  engine_version                  = "5.7"
  instance_class                  = "db.t3.micro"
  allocated_storage               = 10
  db_name                         = var.db_name
  username                        = var.db_username
  password                        = var.db_password
  multi_az                        = true
  db_subnet_group_name            = aws_db_subnet_group.db.name
  vpc_security_group_ids          = [aws_security_group.sg_db.id]
  skip_final_snapshot             = true
  deletion_protection             = false
  publicly_accessible             = false
  auto_minor_version_upgrade      = true
  backup_retention_period         = 1
  performance_insights_enabled    = false
  apply_immediately               = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}rds-mysql"
  })
}
