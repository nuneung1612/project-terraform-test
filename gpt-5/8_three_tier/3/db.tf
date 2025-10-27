# -----------------------------
# db.tf
# -----------------------------
resource "aws_db_subnet_group" "this" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = [aws_subnet.db_az1.id, aws_subnet.db_az2.id]

  tags = {
    Name = "three-tier-db-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier              = "three-tier-mysql"
  allocated_storage       = 10
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t3.micro"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  multi_az                = true
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  skip_final_snapshot     = true
  deletion_protection     = false
  publicly_accessible     = false
  backup_retention_period = 0

  tags = {
    Name = "three-tier-rds-mysql"
    Tier = "db"
  }
}