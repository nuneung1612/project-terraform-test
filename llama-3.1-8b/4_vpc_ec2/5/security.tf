resource "aws_security_group" "public" {
  name        = "Example Public Security Group"
  description = "Public security group"
  vpc_id      = aws_vpc.example.id
  tags        = merge(var.tags, { Name = "Example Public Security Group" })

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

resource "aws_security_group" "private" {
  name        = "Example Private Security Group"
  description = "Private security group"
  vpc_id      = aws_vpc.example.id
  tags        = merge(var.tags, { Name = "Example Private Security Group" })

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.private_ssh_from]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
