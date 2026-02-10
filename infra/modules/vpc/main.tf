# Create a VPC
resource "aws_vpc" "coderco_vpc" {

  tags = {
    Name = "coderco-vpc"
  }
}

#internet gateway
resource "aws_internet_gateway" "coderco_igw" {
  vpc_id = aws_vpc.coderco_vpc.id

  tags = {
    Name = "ecs_internet_gateway"
  }
}

#route table for vpc.
resource "aws_route_table" "ecs_route_table" {
  vpc_id = aws_vpc.coderco_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.coderco_igw.id
  }


  tags = {
    Name = "coderco_rt"
  }
}


#public subnet
resource "aws_subnet" "primary_subnet" {
  vpc_id                  = aws_vpc.coderco_vpc.id
  cidr_block              = var.primary_subnet
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

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
  vpc_id                  = aws_vpc.coderco_vpc.id
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  depends_on              = [aws_subnet.primary_subnet]

  tags = {
    Name = "alb_subnet"
  }
}

# Private subnets for RDS (no internet access)
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.coderco_vpc.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "private_subnet_1"
  }
}

#private subnet for ecs
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.coderco_vpc.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "private_subnet_2"
  }
}

# Private route table (no internet gateway route)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.coderco_vpc.id

  tags = {
    Name = "private_rt"
  }
}


resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

#security group for ecs
resource "aws_security_group" "ecs_security_group" {
  vpc_id = aws_vpc.coderco_vpc.id

  ingress {
    protocol  = "tcp"
    self      = true
    from_port = 80
    to_port   = 80
    #allow ip address from range.
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    self      = true
    from_port = 443
    to_port   = 443
    #allow HTTPS access
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    self      = true
    from_port = 3000
    to_port   = 3000
    #allow container port access
    cidr_blocks = ["192.168.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs_security_group"
  }
}

#security group for rds
resource "aws_security_group" "rds_security_group" {
  vpc_id = aws_vpc.coderco_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.ecs_security_group.id]
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
