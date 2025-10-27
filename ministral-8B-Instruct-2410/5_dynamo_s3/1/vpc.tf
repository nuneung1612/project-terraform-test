resource "aws_vpc" "main" {
  cidr_block                = "10.0.0.0/16"
  default_network_acl_id    = aws_network_acl.main.id
  default_route_table_id    = aws_route_table.main.id
  default_security_group_id = aws_security_group.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}
