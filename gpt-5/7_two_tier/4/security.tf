# security.tf
# Public Security Group
resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Allow HTTP/SSH from anywhere; all egress"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "public-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_http" {
  security_group_id = aws_security_group.public_sg.id
  description       = "HTTP from anywhere"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "public_ssh" {
  security_group_id = aws_security_group.public_sg.id
  description       = "SSH from anywhere"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "public_all_egress" {
  security_group_id = aws_security_group.public_sg.id
  description       = "All outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Private Security Group
resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Allow MySQL from VPC and public-sg; SSH from anywhere; all egress"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "private-sg"
  }
}

# MySQL from entire VPC CIDR
resource "aws_vpc_security_group_ingress_rule" "private_mysql_vpc" {
  security_group_id = aws_security_group.private_sg.id
  description       = "MySQL from VPC CIDR"
  from_port         = 3306
  to_port           = 3306
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

# MySQL from public SG (instances in public-sg)
resource "aws_vpc_security_group_ingress_rule" "private_mysql_from_publicsg" {
  security_group_id            = aws_security_group.private_sg.id
  description                  = "MySQL from public-sg"
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.public_sg.id
}

# SSH from anywhere (per requirement)
resource "aws_vpc_security_group_ingress_rule" "private_ssh" {
  security_group_id = aws_security_group.private_sg.id
  description       = "SSH from anywhere"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "private_all_egress" {
  security_group_id = aws_security_group.private_sg.id
  description       = "All outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ALB Security Group (allow all in/out as specified)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow all inbound and outbound (per requirement)"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_all_in" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "All inbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_all_out" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "All outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
