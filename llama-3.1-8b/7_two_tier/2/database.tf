# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

# RDS Instance
resource "aws_db_instance" "db_instance" {
  identifier        = "db-instance"
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = 10
  username          = var.username
  password          = var.password
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  publicly_accessible = false
  skip_final_snapshot = true
  tags = {
    Name = "twotierdatabase"
  }
}
