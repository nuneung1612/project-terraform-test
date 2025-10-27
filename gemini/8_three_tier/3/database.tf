# --- DB Subnet Group ---
resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = [aws_subnet.db-subnet-a.id, aws_subnet.db-subnet-b.id]

  tags = {
    Name = "three-tier-db-subnet-group"
  }
}

# --- Security Group ---
resource "aws_security_group" "db-sg" {
  name        = "three-tier-db-sg"
  description = "Allow MySQL traffic from the application tier"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    description     = "MySQL from App Tier Instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app-instance-sg.id]
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

# --- RDS Instance ---
resource "aws_db_instance" "three-tier-db" {
  identifier           = "three-tier-db-instance"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  allocated_storage    = 10
  storage_type         = "gp2"
  db_name              = "mydb"
  username             = var.db-username
  password             = var.db-password
  db_subnet_group_name = aws_db_subnet_group.db-subnet-group.name
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  multi_az             = true
  skip_final_snapshot  = true

  tags = {
    Name = "three-tier-db-instance"
  }
}
