# Web Tier Security Groups
resource "aws_security_group" "web_alb" {
  name        = "three-tier-web-alb-sg"
  description = "Allow HTTP inbound traffic to Web ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-web-alb-sg"
  }
}

resource "aws_security_group" "web_instance" {
  name        = "three-tier-web-instance-sg"
  description = "Allow traffic from Web ALB and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from Web ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_alb.id]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-web-instance-sg"
  }
}


# App Tier Security Groups
resource "aws_security_group" "app_alb" {
  name        = "three-tier-app-alb-sg"
  description = "Allow HTTP from Web Tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from Web Tier instances"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_instance.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-app-alb-sg"
  }
}

resource "aws_security_group" "app_instance" {
  name        = "three-tier-app-instance-sg"
  description = "Allow traffic from App ALB and SSH from web tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from App ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app_alb.id]
  }

  ingress {
    description     = "SSH from Web Tier instances"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_instance.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-app-instance-sg"
  }
}


# Database Tier Security Group
resource "aws_security_group" "db" {
  name        = "three-tier-db-sg"
  description = "Allow MySQL traffic from App Tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from App Tier instances"
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
