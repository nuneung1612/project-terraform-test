resource "aws_db_subnet_group" "main" {
  name       = "db-subnet"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "db-subnet"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "db-instance"
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = 10
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.private.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "db-instance"
  }
}