resource "aws_db_subnet_group" "three-tier-db-subnet-group" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = [aws_subnet.three-tier-db-subnet-1a.id, aws_subnet.three-tier-db-subnet-1b.id]
}

resource "aws_db_instance" "three-tier-db-instance" {
  identifier           = "three-tier-db-instance"
  instance_class       = "db.t3.micro"
  engine               = "mysql"
  engine_version       = "5.7"
  username             = var.db-username
  password             = var.db-password
  vpc_security_group_ids = [aws_security_group.three-tier-db-sg.id]
  db_subnet_group_name = aws_db_subnet_group.three-tier-db-subnet-group.name
  skip_final_snapshot  = true
  multi_az             = true
  storage_type         = "gp2"
  allocated_storage    = 10
  tags = {
    Name = "three-tier-db-instance"
  }
}
