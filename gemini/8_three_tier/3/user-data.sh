#!/bin/bash
# A simple user data script to install a web server.
# This script will be used for both web and app tiers.
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
