# Create a VPC
resource "aws_vpc" "coderco_vpc" {
  cidr_block = var.cidr_block
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
#public subnet using for each
resource "aws_subnet" "public_subnet" {
 count = 2
 vpc_id                  = aws_vpc.coderco_vpc.id

  cidr_block              = public_subnets[count.index].cidr
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_${count.index}"
  }
}


# Private subnets for RDS (no internet access)
resource "aws_subnet" "private_subnet_1" {
  count = 2 
  vpc_id                  = aws_vpc.coderco_vpc.id
  cidr_block              = private_subnets[count.index].cidr
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet_${count.index}"
  }
}
# Private route table (no internet gateway route)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.coderco_vpc.id

  tags = {
    Name = "private_rt"
  }
}

#route table for private subnet
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

  tags = {
    Name = "ecs_security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_http_ingress" {
  security_group_id = aws_security_group.ecs_security_group.id

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_https_ingress" {
  security_group_id = aws_security_group.ecs_security_group.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_app_3000_ingress" {
  security_group_id = aws_security_group.ecs_security_group.id

  ip_protocol = "tcp"
  from_port   = 3000
  to_port     = 3000
  cidr_ipv4   = "192.168.1.0/24"
}

resource "aws_vpc_security_group_egress_rule" "ecs_all_egress" {
  security_group_id = aws_security_group.ecs_security_group.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

#security group for rds
resource "aws_security_group" "rds_security_group" {
  vpc_id = aws_vpc.coderco_vpc.id

  tags = {
    Name = "rds_security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_postgres_from_ecs" {
  security_group_id = aws_security_group.rds_security_group.id

  ip_protocol              = "tcp"
  from_port                = 5432
  to_port                  = 5432
  referenced_security_group_id = aws_security_group.ecs_security_group.id
}

resource "aws_vpc_security_group_egress_rule" "rds_all_egress" {
  security_group_id = aws_security_group.rds_security_group.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
