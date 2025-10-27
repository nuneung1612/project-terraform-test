# Create a DB subnet group for the RDS instance
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private_subnets : subnet.id]

  tags = {
    Name = "main-db-subnet-group"
  }
}

# Create the RDS MySQL instance
resource "aws_db_instance" "main_db" {
  identifier           = "main-db-instance"
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  allocated_storage    = 5
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  multi_az             = false
  publicly_accessible  = false
  skip_final_snapshot  = true

  tags = {
    Name = "main-database"
  }
}