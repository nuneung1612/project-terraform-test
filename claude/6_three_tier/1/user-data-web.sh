#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Three-Tier Architecture - Web Tier</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            background-color: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center;
        }
        h1 {
            color: #232f3e;
        }
        .info {
            margin-top: 20px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to the Web Tier</h1>
        <p class="info">Instance ID: <strong>$(ec2-metadata --instance-id | cut -d " " -f 2)</strong></p>
        <p class="info">Availability Zone: <strong>$(ec2-metadata --availability-zone | cut -d " " -f 2)</strong></p>
        <p class="info">This is the web tier of a three-tier architecture</p>
    </div>
</body>
</html>
EOF