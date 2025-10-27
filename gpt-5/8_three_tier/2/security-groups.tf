############################
# security-groups.tf
############################
# Web ALB SG: HTTP from anywhere
resource "aws_security_group" "sg_web_alb" {
  name        = "${var.name_prefix}sg-web-alb"
  description = "Allow HTTP from Internet to Web ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}sg-web-alb" }
}

# Web instances SG: HTTP from Web ALB, SSH from anywhere
resource "aws_security_group" "sg_web_asg" {
  name        = "${var.name_prefix}sg-web-asg"
  description = "Allow HTTP from Web ALB, SSH from anywhere"
  vpc_id      = aws_vpc.this.id

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
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}sg-web-asg" }
}

# App ALB SG: HTTP from Web tier SG
resource "aws_security_group" "sg_app_alb" {
  name        = "${var.name_prefix}sg-app-alb"
  description = "Allow HTTP from Web tier"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "HTTP from Web tier"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_web_asg.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}sg-app-alb" }
}

# App instances SG: HTTP from App ALB, SSH from Web instances
resource "aws_security_group" "sg_app_asg" {
  name        = "${var.name_prefix}sg-app-asg"
  description = "Allow HTTP from App ALB, SSH from Web instances"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "HTTP from App ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_app_alb.id]
  }

  ingress {
    description     = "SSH from Web instances"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_web_asg.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}sg-app-asg" }
}

# DB SG: 3306 from App tier only
resource "aws_security_group" "sg_db" {
  name        = "${var.name_prefix}sg-db"
  description = "Allow MySQL from App tier only"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "MySQL from App instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_app_asg.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}sg-db" }
}
