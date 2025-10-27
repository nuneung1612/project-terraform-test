// security.tf
# Web Tier Security Groups
resource "aws_security_group" "sg_web_alb" {
  name        = "${local.name_prefix}sg-web-alb"
  description = "Allow HTTP from internet to Web ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from Internet"
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

  tags = merge(local.common_tags, { Name = "${local.name_prefix}sg-web-alb" })
}

resource "aws_security_group" "sg_web_instances" {
  name        = "${local.name_prefix}sg-web-instances"
  description = "Allow HTTP from Web ALB and SSH from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from Web ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_web_alb.id]
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

  tags = merge(local.common_tags, { Name = "${local.name_prefix}sg-web-instances" })
}

# Application Tier Security Groups
resource "aws_security_group" "sg_app_alb" {
  name        = "${local.name_prefix}sg-app-alb"
  description = "Allow HTTP from Web Tier SG only (internet-facing ALB with restricted source)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from Web Tier SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_web_instances.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}sg-app-alb" })
}

resource "aws_security_group" "sg_app_instances" {
  name        = "${local.name_prefix}sg-app-instances"
  description = "Allow HTTP from App ALB and SSH from Web Instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from App ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_app_alb.id]
  }

  ingress {
    description     = "SSH from Web Instances"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_web_instances.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}sg-app-instances" })
}

# Database Tier Security Group
resource "aws_security_group" "sg_db" {
  name        = "${local.name_prefix}sg-db"
  description = "Allow MySQL from App Tier only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from App Instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_app_instances.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}sg-db" })
}
