# Create a VPC
resource "aws_vpc" "coderco_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "coderco-vpc"
  }
}

#internet gateway
#

#attached gateway
#
#

#public subnet
resource "aws_subnet" "primary_subnet" {
  vpc_id     = aws_vpc.coderco_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "main_subnet"
  }
}

#public subnet 2
resource "aws_subnet" "secondary_subnet" {
  vpc_id     = aws_vpc.coderco_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "alb_subnet"
  }
}
