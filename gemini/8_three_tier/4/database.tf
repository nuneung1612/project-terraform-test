resource "aws_db_subnet_group" "three_tier" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.db : subnet.id]

  tags = {
    Name = "three-tier-db-subnet-group"
  }
}

resource "aws_db_instance" "three_tier" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = var.db-name
  username             = var.db-username
  password             = var.db-password
  db_subnet_group_name = aws_db_subnet_group.three_tier.name
  vpc_security_group_ids = [aws_security_group.db.id]
  multi_az             = true
  skip_final_snapshot  = true

  tags = {
    Name = "three-tier-db-instance"
  }
}
