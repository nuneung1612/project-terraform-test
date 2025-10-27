# database.tf
resource "aws_db_subnet_group" "three-tier-db-subnet-group" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = aws_subnet.three-tier-db-subnet[*].id

  tags = {
    Name = "three-tier-db-subnet-group"
  }
}

resource "aws_db_instance" "three-tier-rds" {
  identifier             = "three-tier-rds"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.db-instance-class
  allocated_storage      = var.db-allocated-storage
  db_name                = var.db-name
  username               = var.db-username
  password               = var.db-password
  db_subnet_group_name   = aws_db_subnet_group.three-tier-db-subnet-group.name
  vpc_security_group_ids = [aws_security_group.three-tier-db-sg.id]
  multi_az               = true
  skip_final_snapshot    = true

  tags = {
    Name = "three-tier-rds"
  }
}