////////////////////////////////////////////////////////////////////////////////
// database.tf
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "db-subnet"
  }
}

resource "aws_db_instance" "db" {
  identifier               = "db-instance"
  allocated_storage        = 10
  engine                   = var.db_engine
  engine_version           = var.db_engine_version
  instance_class           = var.db_instance_class
  db_name                  = var.db_name
  username                 = var.db_username
  password                 = var.db_password
  db_subnet_group_name     = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids   = [aws_security_group.private_sg.id]
  publicly_accessible      = false
  skip_final_snapshot      = true
  delete_automated_backups = true

  tags = {
    Name = "db-instance"
  }

  depends_on = [
    aws_db_subnet_group.db_subnet,
    aws_security_group.private_sg
  ]
}