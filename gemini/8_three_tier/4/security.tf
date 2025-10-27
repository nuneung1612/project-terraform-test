resource "aws_security_group" "web_alb" {
  name        = "three-tier-web-alb-sg"
  description = "Allow HTTP inbound traffic to the web ALB"
  vpc_id      = aws_vpc.three_tier.id

  ingress {
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
  description = "Allow HTTP from web ALB and SSH from anywhere"
  vpc_id      = aws_vpc.three_tier.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_alb.id]
  }

  ingress {
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

resource "aws_security_group" "app_alb" {
  name        = "three-tier-app-alb-sg"
  description = "Allow HTTP inbound traffic from the web tier"
  vpc_id      = aws_vpc.three_tier.id

  ingress {
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
  description = "Allow HTTP from app ALB and SSH from web tier"
  vpc_id      = aws_vpc.three_tier.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app_alb.id]
  }

  ingress {
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

resource "aws_security_group" "db" {
  name        = "three-tier-db-sg"
  description = "Allow MySQL traffic from the app tier"
  vpc_id      = aws_vpc.three_tier.id

  ingress {
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
