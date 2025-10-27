resource "aws_security_group" "db-sg" {
  vpc_id = aws_vpc.main.id
  name   = "three-tier-db-sg"

  tags = {
    Name = "three-tier-db-sg"
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app-instance-sg.id]
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = [aws_subnet.db-a.id, aws_subnet.db-b.id]

  tags = {
    Name = "three-tier-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  allocated_storage      = var.db_storage
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.db_instance_type
  name                   = "mydb"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "three-tier-db-instance"
  }
}
