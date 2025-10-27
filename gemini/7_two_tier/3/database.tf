# database.tf
resource "aws_db_instance" "db_instance" {
  identifier           = "db-instance"
  allocated_storage    = 10
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  publicly_accessible  = false
  skip_final_snapshot  = true

  tags = {
    Name = "db-instance"
  }
}