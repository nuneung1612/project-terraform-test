# AWS Configuration
aws-region = "us-east-1"

# Network Configuration
vpc-cidr           = "10.0.0.0/16"
availability-zones = ["us-east-1a", "us-east-1b"]
web-subnet-cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
app-subnet-cidrs   = ["10.0.3.0/24", "10.0.4.0/24"]
db-subnet-cidrs    = ["10.0.5.0/24", "10.0.6.0/24"]

# Compute Configuration
ami-id         = "ami-052064a798f08f0d3"
instance-type  = "t2.micro"
key-pair-name  = "3-tier-key-pair"

# Auto Scaling Configuration
web-asg-min-size          = 1
web-asg-desired-capacity  = 2
web-asg-max-size          = 4

app-asg-min-size          = 1
app-asg-desired-capacity  = 2
app-asg-max-size          = 4

# Database Configuration
db-instance-class    = "db.t3.micro"
db-name              = "mydb"
db-username          = "admin"
db-password          = "YourSecurePasswordHere123!"
db-allocated-storage = 10