resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Public security group for web instances"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-sg"
  }
}

resource "aws_security_group_rule" "public_http_in" {
  type              = "ingress"
  security_group_id = aws_security_group.public_sg.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP from anywhere"
}

resource "aws_security_group_rule" "public_ssh_in" {
  type              = "ingress"
  security_group_id = aws_security_group.public_sg.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "SSH from anywhere"
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Private security group for DB"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}

resource "aws_security_group_rule" "private_mysql_from_vpc" {
  type              = "ingress"
  security_group_id = aws_security_group.private_sg.id
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  description       = "MySQL from VPC"
}

resource "aws_security_group_rule" "private_mysql_from_public_sg" {
  type                     = "ingress"
  security_group_id        = aws_security_group.private_sg.id
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_sg.id
  description              = "MySQL from public-sg"
}

resource "aws_security_group_rule" "private_ssh_in" {
  type              = "ingress"
  security_group_id = aws_security_group.private_sg.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "SSH from anywhere"
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "ALB security group allowing all"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "All inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}