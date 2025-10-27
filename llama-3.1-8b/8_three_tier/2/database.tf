# Security Group
resource "aws_security_group" "three-tier-db-sg" {
  name        = "three-tier-db-sg"
  description = "Security Group for Database Tier"
  vpc_id      = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-db-sg"
  }
}

resource "aws_security_group_rule" "three-tier-db-sg-mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.three-tier-db-sg.id
  source_security_group_id = aws_security_group.three-tier-app-sg.id
}

# RDS
resource "aws_db_subnet_group" "three-tier-db-subnet-group" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = [aws_subnet.three-tier-db-subnet-1.id, aws_subnet.three-tier-db-subnet-2.id]
  tags = {
    Name = "three-tier-db-subnet-group"
  }
}

resource "aws_db_instance" "three-tier-rds" {
  identifier              = "three-tier-rds"
  instance_class          = "db.t3.micro"
  engine                  = "mysql"
  engine_version          = "5.7"
  username                = var.db_username
  password                = var.db_password
  vpc_security_group_ids  = [aws_security_group.three-tier-db-sg.id]
  db_subnet_group_name    = aws_db_subnet_group.three-tier-db-subnet-group.name
  skip_final_snapshot     = true
  vpc_id                  = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-rds"
  }
}
