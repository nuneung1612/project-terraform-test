resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "three-tier-db-subnet-group"
  }
}

resource "aws_rds_cluster" "main" {
  cluster_identifier      = "three-tier-rds-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.08.1"
  master_username         = var.db_username
  master_password         = var.db_password
  storage_encrypted       = true
  apply_immediately       = true
  backup_retention_period = 5
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot     = true

  scaling_configuration {
    auto_pause = false
    max_capacity = 2
    min_capacity = 1
    seconds_until_auto_pause = 300
  }

  tags = {
    Name = "three-tier-rds-cluster"
  }
}

resource "aws_rds_cluster_instance" "main" {
  count              = 2
  identifier         = "three-tier-rds-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.t3.micro"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
  publicly_accessible = false
  apply_immediately  = true

  tags = {
    Name = "three-tier-rds-instance-${count.index}"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "three-tier-db-sg"
  description = "Security group for RDS instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.security_group_db]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "db_subnet_group" {
  value = aws_db_subnet_group.db_subnet_group
}

output "security_group_db" {
  value = aws_security_group.db_sg
}
