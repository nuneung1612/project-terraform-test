#!/bin/bash

# Log everything
exec > >(tee /var/log/user-data.log)
exec 2>&1

set -x

# Update system
yum update -y

# Install NFS utilities and EFS helper
yum install -y amazon-efs-utils nfs-utils

# Create mount point
mkdir -p ${mount_point}

# Wait for EFS to be available
sleep 30

# Mount EFS using NFS4 (more reliable than efs helper in some cases)
# Option 1: Using EFS helper (TLS enabled)
echo "${efs_id}:/ ${mount_point} efs _netdev,noresvport,tls 0 0" >> /etc/fstab

# Try to mount
mount -a -t efs

# If EFS helper fails, try standard NFS mount
if ! mountpoint -q ${mount_point}; then
    echo "EFS helper mount failed, trying NFS4..."
    # Get EFS DNS name
    EFS_DNS="${efs_id}.efs.${aws_region}.amazonaws.com"
    
    # Remove the efs entry from fstab
    sed -i '/${efs_id}/d' /etc/fstab
    
    # Add NFS4 mount to fstab
    echo "$EFS_DNS:/ ${mount_point} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
    
    # Mount using NFS4
    mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $EFS_DNS:/ ${mount_point}
fi

# Verify mount
if mountpoint -q ${mount_point}; then
    echo "EFS mounted successfully!"
else
    echo "EFS mount failed!"
    exit 1
fi

# Set proper permissions
chmod 755 ${mount_point}

# Create a test file to verify EFS is working
echo "Hello from Instance ${instance_num} - $(date)" > ${mount_point}/instance-${instance_num}.txt

# Install and start Apache web server
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create a simple web page
cat > /var/www/html/index.html <<'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <title>Instance ${instance_num}</title>
</head>
<body>
    <h1>Instance ${instance_num}</h1>
    <p>EFS Mount Point: ${mount_point}</p>
    <p>EFS ID: ${efs_id}</p>
    <p>Hostname: $(hostname)</p>
    <p>Region: ${aws_region}</p>
</body>
</html>
HTMLEOF

# Set permissions
chmod -R 755 /var/www/html

echo "User data script completed successfully!"