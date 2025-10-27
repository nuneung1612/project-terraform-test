// database.tf

# DB subnet group (private subnets)
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "twotier-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = merge(local.common_tags, {
    Name = "twotier-db-subnet-group"
  })
}

# RDS MySQL Instance
resource "aws_db_instance" "mysql" {
  identifier                 = "twotier-mysql"
  engine                     = var.db_engine
  engine_version             = var.db_engine_version
  instance_class             = var.rds_instance_class
  allocated_storage          = var.rds_allocated_storage
  db_name                    = var.db_name
  username                   = var.db_username
  password                   = var.db_password
  db_subnet_group_name       = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids     = [aws_security_group.private_db_sg.id]
  multi_az                   = false
  publicly_accessible        = false
  storage_type               = "gp3"
  skip_final_snapshot        = true
  auto_minor_version_upgrade = true
  apply_immediately          = true

  tags = merge(local.common_tags, {
    Name = "twotier-mysql"
    Role = "database"
  })

  depends_on = [
    aws_route_table_association.private_rt_assoc_1,
    aws_route_table_association.private_rt_assoc_2
  ]
}
