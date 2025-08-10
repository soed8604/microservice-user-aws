region = "us-east-1"
name   = "jelou-dev"

azs             = ["us-east-1a", "us-east-1b"]
cidr            = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

db_name     = "mydatabase"
db_username = "myuser"
db_password = "mypassword"
db_ssl      = true
image_tag   = "latest"
image       = "026090531008.dkr.ecr.us-east-1.amazonaws.com/jelou-dev-repo:v1.0.1"