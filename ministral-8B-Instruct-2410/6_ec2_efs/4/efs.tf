resource "aws_efs_file_system" "efs" {
  creation_token = var.project_name
  encrypted      = true
  tags = {
    Name = "${var.project_name}-efs"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count           = 2
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = element(aws_subnet.public[*].id, count.index)
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_lifecycle_policy" "efs_lifecycle_policy" {
  file_system_id = aws_efs_file_system.efs.id
  policy = jsonencode({
    Rules = [
      {
        ID             = "TransitionToIA"
        Prefix         = "/"
        Status         = "TRANSITIONING"
        Days           = 30
        TransitionToIA = true
      }
    ]
  })
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id
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
  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

resource "aws_security_group" "efs_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-efs-sg"
  }
}

output "efs_id" {
  value = aws_efs_file_system.efs.id
}
