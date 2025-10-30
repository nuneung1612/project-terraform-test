# Create DB subnet group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet"
  description = "DB subnet group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

# Create RDS instance
resource "aws_db_instance" "db_instance" {
  allocated_storage    = 10
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  name                 = var.db_name
  username             = var.username
  password             = var.password
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  skip_final_snapshot = true
  publicly_accessible = false
  tags = {
    Name = "db-instance"
  }
}
