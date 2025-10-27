#!/bin/bash  
sudo yum install httpd -y -q
sleep 15
sudo yum install php  -y -q
sleep 5
sudo systemctl start httpd
sleep 5
sudo systemctl enable httpd
sleep 5
sudo yum install nfs-utils -y -q 
sleep 15
sudo service rpcbind restart
sleep 15
#Mounting Efs
# efs_dns_name="${efs_dns_name}"
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns_name}:/  /var/www/html
sleep 15
sudo chmod go+rw /var/www/html
sudo bash -c 'echo Welcome  > /var/www/html/index.html'

# yum install -y amazon-efs-utils
# mkdir -p /var/www/html

# efs_dns_name="${efs_dns_name}"

# echo "Mounting EFS: ${efs_dns_name}"
# sudo mount -t efs -o tls ${efs_dns_name}:/ /var/www/html

# echo "${efs_dns_name}:/ /var/www/html efs _netdev,tls,nfsvers=4.1 0 0" >> /etc/fstab