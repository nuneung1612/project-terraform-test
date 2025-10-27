resource "aws_security_group" "db" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "three-tier-db-sg"
  }
}

resource "aws_security_group_rule" "db_mysql_ingress" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id = aws_security_group.db.id
}

resource "aws_db_subnet_group" "main" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = [aws_subnet.db_us-east-1a.id, aws_subnet.db_us-east-1b.id]
  tags = {
    Name = "three-tier-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = var.db_instance_type
  name              = var.db_name
  username          = var.db_username
  password          = var.db_password
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name = aws_db_subnet_group.main.id
  skip_final_snapshot = true
  tags = {
    Name = "three-tier-db-instance"
  }
}
