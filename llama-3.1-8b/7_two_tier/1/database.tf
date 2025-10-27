resource "aws_db_instance" "main" {
  engine           = var.database_engine
  engine_version   = var.database_version
  instance_class   = var.instance_class
  allocated_storage = var.allocated_storage
  username         = var.master_username
  password         = var.master_password
  vpc_security_group_ids = [aws_security_group.private.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  skip_final_snapshot = true
  tags = {
    Name = "twotierdatabase"
  }
}

# Create DB subnet group
resource "aws_db_subnet_group" "main" {
  name       = "main-dbsubnet-group"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]
  tags = {
    Name = "main-dbsubnet-group"
  }
}
