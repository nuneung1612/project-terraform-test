#!/bin/bash
# A simple placeholder script to install a web server
# This script will be used for both web and application tiers
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello from Tier Instance</h1>" > /var/www/html/index.html


#gen มาเกิน