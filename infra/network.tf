module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "192.168.1.0/24"
  tags = {
    Name = "MyVPC"
  }
  primary_subnet     = "192.168.1.0/25"
  availability_zones = ["us-east-1a", "us-east-1b"]
}
