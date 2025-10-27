# Web Tier ALB Security Group
resource "aws_security_group" "three-tier-web-alb-sg" {
  name        = "three-tier-web-alb-sg"
  description = "Security group for web tier ALB"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-web-alb-sg"
  }
}

# Web Tier Instance Security Group
resource "aws_security_group" "three-tier-web-instance-sg" {
  name        = "three-tier-web-instance-sg"
  description = "Security group for web tier instances"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    description     = "HTTP from web ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three-tier-web-alb-sg.id]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-web-instance-sg"
  }
}

# App Tier ALB Security Group
resource "aws_security_group" "three-tier-app-alb-sg" {
  name        = "three-tier-app-alb-sg"
  description = "Security group for app tier ALB"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    description     = "HTTP from web tier security group"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three-tier-web-instance-sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-app-alb-sg"
  }
}

# App Tier Instance Security Group
resource "aws_security_group" "three-tier-app-instance-sg" {
  name        = "three-tier-app-instance-sg"
  description = "Security group for app tier instances"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    description     = "HTTP from app ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three-tier-app-alb-sg.id]
  }

  ingress {
    description     = "SSH from web tier instances"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.three-tier-web-instance-sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-app-instance-sg"
  }
}

# Database Security Group
resource "aws_security_group" "three-tier-db-sg" {
  name        = "three-tier-db-sg"
  description = "Security group for database tier"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    description     = "MySQL from app tier security group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.three-tier-app-instance-sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-db-sg"
  }
}