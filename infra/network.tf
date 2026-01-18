# Create a VPC
resource "aws_vpc" "coderco_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "coderco-vpc"
  }
}

#internet gateway
resource "aws_internet_gateway" "coderco-igw" {
  vpc_id = aws_vpc.coderco_vpc.id

  tags = {
    Name = "ecs_internet_gateway"
  }
}

#attached gateway
resource "aws_nat_gateway" "main_attach" {
  subnet_id = aws_subnet.primary_subnet.id

  tags = {
    Name = "ecs_nat_gateway"
  }
}

#secondary attachment
resource "aws_nat_gateway" "secondary_attach" {
  subnet_id = aws_subnet.secondary_subnet.id

  tags = {
    Name = "secondary_attach"
  }
}

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
