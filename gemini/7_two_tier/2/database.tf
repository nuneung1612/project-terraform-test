// database.tf
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  description = "DB subnet group for private subnets"

  tags = {
    Name = "db-subnet"
  }
}

resource "aws_db_instance" "db" {
  allocated_storage      = 10
  db_name                = var.db_name
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  identifier             = "db-instance"
  username               = var.db_username
  password               = var.db_password # Sensitive value from variables.tf
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "db-instance"
  }
}