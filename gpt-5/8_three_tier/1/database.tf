# database.tf
resource "aws_db_subnet_group" "three_tier_db_subnets" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = [for s in aws_subnet.three_tier_db : s.id]

  tags = {
    Name = "three-tier-db-subnet-group"
  }
}

# DB SG: allow MySQL from App Instance SG only
resource "aws_security_group" "three_tier_db_sg" {
  name        = "three-tier-sg-db"
  description = "three-tier DB SG, MySQL from app instances only"
  vpc_id      = aws_vpc.three_tier.id

  ingress {
    description     = "MySQL from app instances SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_app_instance_sg.id]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "three-tier-sg-db" }
}

resource "aws_db_instance" "three_tier_mysql" {
  identifier                 = "three-tier-rds-mysql57"
  engine                     = "mysql"
  engine_version             = "5.7"
  instance_class             = "db.t3.micro"
  allocated_storage          = 10
  storage_type               = "gp3"
  multi_az                   = true
  db_subnet_group_name       = aws_db_subnet_group.three_tier_db_subnets.name
  vpc_security_group_ids     = [aws_security_group.three_tier_db_sg.id]
  db_name                    = "mydb"
  username                   = var.db_username
  password                   = var.db_password
  publicly_accessible        = false
  backup_retention_period    = 7
  auto_minor_version_upgrade = true
  deletion_protection        = false
  skip_final_snapshot        = true

  tags = {
    Name   = "three-tier-rds"
    Engine = "mysql-5.7"
  }
}

output "db_endpoint" {
  value     = aws_db_instance.three_tier_mysql.address
  sensitive = true
}
