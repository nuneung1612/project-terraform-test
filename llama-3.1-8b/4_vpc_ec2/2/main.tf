resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(var.public_tags, {
    Name        = "Main VPC"
    Environment = "Development"
  })
}

# Create public subnet
resource "aws_subnet" "public" {
  cidr_block = var.public_subnet_cidr
  vpc_id     = aws_vpc.main.id
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
  tags = merge(var.public_tags, {
    Name        = "Public Subnet"
    Environment = "Development"
  })
}

# Create private subnet
resource "aws_subnet" "private" {
  cidr_block = var.private_subnet_cidr
  vpc_id     = aws_vpc.main.id
  availability_zone = var.availability_zone
  tags = merge(var.private_tags, {
    Name        = "Private Subnet"
    Environment = "Development"
  })
}

# Create public security group
resource "aws_security_group" "public" {
  name        = var.public_sg_name
  description = var.public_sg_description
  vpc_id      = aws_vpc.main.id
  tags = merge(var.public_tags, {
    Name        = "Public Security Group"
    Environment = "Development"
  })

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}

# Create private security group
resource "aws_security_group" "private" {
  name        = var.private_sg_name
  description = var.private_sg_description
  vpc_id      = aws_vpc.main.id
  tags = merge(var.private_tags, {
    Name        = "Private Security Group"
    Environment = "Development"
  })

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.public_tags, {
    Name        = "Public Route Table"
    Environment = "Development"
  })
}

# Create public route
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Create public route association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.private_tags, {
    Name        = "Private Route Table"
    Environment = "Development"
  })
}

# Create private route
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = aws_subnet.private.cidr_block
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Create private route association
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Create NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = var.nat_gateway_eip_allocation_id
  subnet_id     = aws_subnet.public.id
  tags = merge(var.public_tags, {
    Name        = "NAT Gateway"
    Environment = "Development"
  })
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.public_tags, {
    Name        = "Internet Gateway"
    Environment = "Development"
  })
}

# Create Elastic IP
resource "aws_eip" "main" {
  vpc = true
  tags = merge(var.public_tags, {
    Name        = "Elastic IP"
    Environment = "Development"
  })
}

# Create NAT Gateway EIP association
resource "aws_eip_association" "main" {
  allocation_id = aws_eip.main.id
  network_interface_id = aws_nat_gateway.main.id
}

# Create bastion instance
resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.public.id]
  subnet_id = aws_subnet.public.id
  key_name = var.ssh_key_name
  tags = merge(var.bastion_tags, {
    Name        = var.bastion_instance_name
    Environment = "Development"
  })
}

# Create private instance
resource "aws_instance" "private" {
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.private.id]
  subnet_id = aws_subnet.private.id
  key_name = var.ssh_key_name
  depends_on = [aws_instance.bastion]
  tags = merge(var.private_tags, {
    Name        = var.private_instance_name
    Environment = "Development"
  })
}
