resource "aws_db_subnet_group" "main" {
  name       = "three-tier-rds-subnet-group"
  subnet_ids = aws_subnet.db[*].id
  tags = {
    Name = "three-tier-rds-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "three-tier-rds-instance"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  multi_az               = true
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db.id]
  tags = {
    Name = "three-tier-rds-instance"
  }
}
