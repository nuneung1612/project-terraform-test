# EC2 Instance Configuration
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.public.id, aws_security_group.private.id]

  subnet_id = aws_subnet.public[0].id

  tags = {
    Name = "example-ec2"
  }
}
