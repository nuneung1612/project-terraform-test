data "template_file" "user_data_web" {
  template = <<EOF
#!/bin/bash
yum update -y
amazon-linux-extras install -y docker
service docker start
chkconfig docker on
EOF
}

data "template_file" "user_data_app" {
  template = <<EOF
#!/bin/bash
yum update -y
amazon-linux-extras install -y docker
service docker start
chkconfig docker on
EOF
}

resource "aws_launch_template" "web" {
  name_prefix = "three-tier-launch-template-web-"
  image_id    = var.ami_id
  instance_type = "t2.micro"
  key_name    = var.key_name
  user_data   = base64encode(data.template_file.user_data_web.rendered)
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.instances_web.id]
  }
}

resource "aws_launch_template" "app" {
  name_prefix = "three-tier-launch-template-app-"
  image_id    = var.ami_id
  instance_type = "t2.micro"
  key_name    = var.key_name
  user_data   = base64encode(data.template_file.user_data_app.rendered)
  network_interfaces {
    security_groups = [aws_security_group.instances_app.id]
  }
}
