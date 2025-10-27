resource "aws_security_group" "three-tier-alb-sg" {
  name        = "three-tier-alb-sg"
  description = "Security group for application load balancer"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "three-tier-web-asg-sg" {
  name        = "three-tier-web-asg-sg"
  description = "Security group for web tier auto scaling group"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three-tier-alb-sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "three-tier-app-asg-sg" {
  name        = "three-tier-app-asg-sg"
  description = "Security group for app tier auto scaling group"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three-tier-web-asg-sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.three-tier-web-asg-sg.id]
  }
}

resource "aws_security_group" "three-tier-db-sg" {
  name        = "three-tier-db-sg"
  description = "Security group for database tier"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.three-tier-app-subnet-1a.cidr_block]
  }
}
