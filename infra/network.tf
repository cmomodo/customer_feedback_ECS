# Create a VPC
resource "aws_vpc" "coderco_vpc" {
  cidr_block = "192.168.1.0/24"

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

#default route table
resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.coderco_vpc.default_route_table_id

  route {
    cidr_block = "192.168.1.0/24"
    gateway_id = aws_internet_gateway.coderco-igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
  }

  tags = {
    Name = "default_route_table"
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
#route table for vpc.
resource "aws_route_table" "ecs_route_table" {
  vpc_id = aws_vpc.coderco_vpc.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.coderco-igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
  }

  tags = {
    Name = "example"
  }
}


#public subnet
resource "aws_subnet" "primary_subnet" {
  vpc_id     = aws_vpc.coderco_vpc.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "main_subnet"
  }
}

#first subnet primary_subnet_association
resource "aws_route_table_association" "primary_subnet_association" {
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.ecs_route_table.id
}

#secondary subnet association
resource "aws_route_table_association" "secondary_subnet_association" {
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.ecs_route_table.id
}

#public subnet 2
resource "aws_subnet" "secondary_subnet" {
  vpc_id     = aws_vpc.coderco_vpc.id
  cidr_block = "192.168.2.0/24"

  tags = {
    Name = "alb_subnet"
  }
}

#security group for ecs
resource "aws_default_security_group" "ecs_security_group" {
  vpc_id = aws_vpc.coderco_vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#security group for rds
resource "aws_default_security_group" "rds_security_group" {
  vpc_id = aws_vpc.coderco_vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
    security_groups = [aws_default_security_group.ecs_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_security_group"
  }
}
