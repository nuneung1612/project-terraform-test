resource "aws_db_subnet_group" "db-subnet" {
  name        = "db-subnet"
  description = "DB subnet group"
  subnet_ids  = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

resource "aws_db_instance" "db-instance" {
  identifier             = "db-instance"
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = 10
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name
  vpc_security_group_ids = [aws_security_group.private-sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  username               = var.username
  password               = var.password
  db_name                = var.db_name
  tags = {
    Name = "db-instance"
  }
}
