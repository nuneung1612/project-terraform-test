# ===================================================================
# database.tf
# ===================================================================

resource "aws_db_subnet_group" "this" {
  name       = "${local.project_prefix}-db-subnet-group"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_b.id]

  tags = {
    Name = "${local.project_prefix}-db-subnet-group"
    Tier = "db"
  }
}

resource "aws_db_instance" "this" {
  identifier                  = "${local.project_prefix}-mysql"
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t3.micro"
  db_name                     = "mydb"
  username                    = var.db_username
  password                    = var.db_password
  allocated_storage           = 10
  storage_type                = "gp3"
  multi_az                    = true
  skip_final_snapshot         = true
  deletion_protection         = false
  publicly_accessible         = false
  vpc_security_group_ids      = [aws_security_group.db.id]
  db_subnet_group_name        = aws_db_subnet_group.this.name
  backup_retention_period     = 1
  auto_minor_version_upgrade  = true
  apply_immediately           = true

  tags = {
    Name = "${local.project_prefix}-rds-mysql"
    Tier = "db"
  }
}