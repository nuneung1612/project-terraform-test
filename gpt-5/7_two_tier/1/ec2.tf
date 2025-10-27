// ec2.tf

data "aws_ami" "selected" {
  # If you prefer to resolve dynamically by filters, adjust this data source.
  # Here we stick to explicit AMI id for determinism, but validate it exists.
  most_recent = true
  owners      = ["self", "amazon", "aws-marketplace"]

  filter {
    name   = "image-id"
    values = [var.ami_id]
  }
}

resource "aws_instance" "web1" {
  ami                         = data.aws_ami.selected.id
  instance_type               = var.ec2_instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "web1"
    Role = "web"
  })
}

resource "aws_instance" "web2" {
  ami                         = data.aws_ami.selected.id
  instance_type               = var.ec2_instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "web2"
    Role = "web"
  })
}
