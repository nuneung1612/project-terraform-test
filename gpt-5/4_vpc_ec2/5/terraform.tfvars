// terraform.tfvars
region             = "us-east-1"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
availability_zone  = "us-east-1a"

ami_id        = "ami-052064a798f08f0d3"
instance_type = "t2.micro"
ssh_key_name  = "vockey"

default_tags = {
  Project     = "vpc-nat-two-tier"
  Environment = "dev"
  ManagedBy   = "terraform"
}
