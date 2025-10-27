resource "aws_db_subnet_group" "main_db_subnet_group" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

resource "aws_db_instance" "main_db" {
  allocated_storage      = 5
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  name                   = var.db_name
  username               = var.db_master_username
  password               = var.db_master_password
  db_subnet_group_name   = aws_db_subnet_group.main_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags = {
    Name = "main-db"
  }
}
