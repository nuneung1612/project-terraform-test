# DB Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.db : subnet.id]

  tags = {
    Name = "three-tier-db-subnet-group"
  }
}

# DB Security Group
resource "aws_security_group" "db" {
  name        = "three-tier-db-sg"
  description = "Allow MySQL traffic from App tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from App Tier Instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_instance.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-db-sg"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "default" {
  identifier           = "three-tier-db"
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = var.db-name
  username             = var.db-username
  password             = var.db-password
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db.id]
  multi_az             = true
  skip_final_snapshot  = true

  tags = {
    Name = "three-tier-rds-instance"
  }
}
