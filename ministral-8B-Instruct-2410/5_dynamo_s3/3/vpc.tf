resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  default_network_acl_id = aws_network_acl.main.id
  default_route_table_id = aws_route_table.main.id
  default_security_group_id = aws_security_group.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_security_group" "main" {
  name   = "main_sg"
  vpc_id = aws_vpc.main_vpc.id

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
    Name = "main"
  }
}
