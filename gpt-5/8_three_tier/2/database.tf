############################
# database.tf
############################
# DB Subnet Group (DB subnets only)
resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}db-subnet-group"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_b.id]

  tags = { Name = "${var.name_prefix}db-subnet-group" }
}

resource "aws_db_instance" "this" {
  identifier              = "${var.name_prefix}mysql"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t3.micro"
  allocated_storage       = 10
  storage_type            = "gp3"
  multi_az                = true
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.sg_db.id]
  publicly_accessible     = false
  username                = var.db_username
  password                = var.db_password
  db_name                 = "mydb"
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = { Name = "${var.name_prefix}rds-mysql" }
}