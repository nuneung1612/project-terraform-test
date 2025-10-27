# Web Tier ALB Security Group
resource "aws_security_group" "web_alb" {
  name        = "three-tier-web-alb-sg"
  description = "Allow HTTP inbound traffic to the web ALB"
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

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-web-alb-sg"
    }
  )
}

# Web Tier Instance Security Group
resource "aws_security_group" "web_instance" {
  name        = "three-tier-web-instance-sg"
  description = "Allow HTTP from web ALB and SSH from anywhere"
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

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-web-instance-sg"
    }
  )
}

# App Tier ALB Security Group
resource "aws_security_group" "app_alb" {
  name        = "three-tier-app-alb-sg"
  description = "Allow HTTP inbound traffic from the web tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from Web Tier Instances"
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

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-app-alb-sg"
    }
  )
}

# App Tier Instance Security Group
resource "aws_security_group" "app_instance" {
  name        = "three-tier-app-instance-sg"
  description = "Allow HTTP from app ALB and SSH from web instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from App ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app_alb.id]
  }

  ingress {
    description     = "SSH from Web Tier Instances"
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

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-app-instance-sg"
    }
  )
}

# Database Security Group
resource "aws_security_group" "db" {
  name        = "three-tier-db-sg"
  description = "Allow MySQL traffic from the application tier"
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

  tags = merge(
    local.common_tags,
    {
      Name = "three-tier-db-sg"
    }
  )
}
