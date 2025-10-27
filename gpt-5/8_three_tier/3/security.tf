# -----------------------------
# security.tf
# -----------------------------
# Web ALB SG: allow HTTP from anywhere
resource "aws_security_group" "web_alb" {
  name        = "three-tier-sg-web-alb"
  description = "Allow HTTP from internet to Web ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-sg-web-alb"
  }
}

# Web instances SG: allow HTTP from web ALB, SSH from anywhere
resource "aws_security_group" "web_instances" {
  name        = "three-tier-sg-web-instances"
  description = "Allow HTTP from Web ALB, SSH from anywhere"
  vpc_id      = aws_vpc.this.id

  ingress {
    description              = "HTTP from Web ALB"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    security_groups          = [aws_security_group.web_alb.id]
    ipv6_cidr_blocks         = []
    prefix_list_ids          = []
    cidr_blocks              = []
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-sg-web-instances"
  }
}

# App ALB SG: allow HTTP from Web instances only
resource "aws_security_group" "app_alb" {
  name        = "three-tier-sg-app-alb"
  description = "Allow HTTP from Web tier to App ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "HTTP from Web instances"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_instances.id]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-sg-app-alb"
  }
}

# App instances SG: allow HTTP from App ALB, SSH from Web instances
resource "aws_security_group" "app_instances" {
  name        = "three-tier-sg-app-instances"
  description = "Allow HTTP from App ALB, SSH from Web instances"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "HTTP from App ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app_alb.id]
  }

  ingress {
    description     = "SSH from Web instances"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_instances.id]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-sg-app-instances"
  }
}

# DB SG: allow MySQL from App instances only
resource "aws_security_group" "db" {
  name        = "three-tier-sg-db"
  description = "Allow MySQL from App tier only"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "MySQL from App instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_instances.id]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-sg-db"
  }
}
