# -----------------------------------------------------------------------------
# Public Security Group (for Bastion/Jump Server)
# -----------------------------------------------------------------------------
resource "aws_security_group" "public_sg" {
  name        = "Public-Bastion-SG"
  description = "Allows inbound HTTP/80 and SSH/22 from 0.0.0.0/0, unrestricted outbound"
  vpc_id      = aws_vpc.main.id

  # Ingress Rules (HTTP and SSH from anywhere)
  ingress {
    description = "Allow inbound HTTP (80)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound SSH (22)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress (Outbound) Rule: Unrestricted
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public-Bastion-SG"
  }
}

# -----------------------------------------------------------------------------
# Private Security Group (for Application Server)
# -----------------------------------------------------------------------------
resource "aws_security_group" "private_sg" {
  name        = "Private-App-SG"
  description = "Allows inbound SSH/22 only from within the VPC, unrestricted outbound"
  vpc_id      = aws_vpc.main.id

  # Ingress Rule: SSH only from within the VPC (10.0.0.0/16)
  ingress {
    description = "Allow inbound SSH (22) from VPC CIDR only (Bastion)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Scopes the rule to the VPC CIDR block, adhering to best practice
    cidr_blocks = [var.vpc_cidr] 
  }

  # Egress (Outbound) Rule: Unrestricted
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private-App-SG"
  }
}
