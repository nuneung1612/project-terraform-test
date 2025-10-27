resource "aws_security_group" "three-tier-db-sg" {
  name        = "three-tier-db-sg"
  description = "Security group for db tier"
  vpc_id      = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-db-sg"
  }
}

resource "aws_security_group_rule" "three-tier-db-sg-allow-mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.three-tier-app-sg.id
  security_group_id = aws_security_group.three-tier-db-sg.id
}

resource "aws_db_subnet_group" "three-tier-db-sg" {
  name       = "three-tier-db-sg"
  subnet_ids = [aws_subnet.three-tier-db-subnet-1.id, aws_subnet.three-tier-db-subnet-2.id]
  tags = {
    Name = "three-tier-db-sg"
  }
}

resource "aws_db_instance" "three-tier-db" {
  identifier           = "three-tier-db"
  instance_class       = var.db_instance_class
  engine               = "mysql"
  engine_version       = "5.7"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.three-tier-db-sg.name
  vpc_security_group_ids = [aws_security_group.three-tier-db-sg.id]
  db_name               = "mydb"
  skip_final_snapshot   = true
  tags = {
    Name = "three-tier-db"
  }
}
