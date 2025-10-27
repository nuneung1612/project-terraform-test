
# ===================================================================
# security-groups.tf
# ===================================================================

# ALB (web) - allow HTTP(80) from internet
resource "aws_security_group" "alb_web" {
  name        = local.name_tags.sg_alb_web
  description = "ALB web - allow HTTP from internet"
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

  tags = { Name = local.name_tags.sg_alb_web }
}

# Web instances - allow HTTP from ALB, SSH from anywhere
resource "aws_security_group" "web_instances" {
  name        = local.name_tags.sg_web_instances
  description = "Web instances - HTTP from ALB, SSH from internet"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "HTTP from web ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_web.id]
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

  tags = { Name = local.name_tags.sg_web_instances }
}

# ALB (app) - internet-facing, but restrict source to web tier SG per requirement
resource "aws_security_group" "alb_app" {
  name        = local.name_tags.sg_alb_app
  description = "App ALB - allow HTTP from web tier SG"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "HTTP from web tier instances SG"
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

  tags = { Name = local.name_tags.sg_alb_app }
}

# App instances - allow HTTP from app ALB, SSH from web tier instances
resource "aws_security_group" "app_instances" {
  name        = local.name_tags.sg_app_instances
  description = "App instances - HTTP from app ALB, SSH from web instances"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "HTTP from app ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_app.id]
  }

  ingress {
    description     = "SSH from web instances"
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

  tags = { Name = local.name_tags.sg_app_instances }
}

# DB SG - allow MySQL from app instances SG only
resource "aws_security_group" "db" {
  name        = local.name_tags.sg_db
  description = "DB - allow MySQL from app instances SG"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "MySQL from app tier SG"
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

  tags = { Name = local.name_tags.sg_db }
}
