# Create a VPC
resource "aws_vpc" "coderco_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "coderco-vpc"
  }
}

resource "aws_internet_gateway" "coderco_igw" {
  vpc_id = aws_vpc.coderco_vpc.id

  tags = {
    Name = "ecs_internet_gateway"
  }
}

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

resource "aws_subnet" "public_subnet" {
  count = 2

  vpc_id                  = aws_vpc.coderco_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_${count.index}"
  }
}

resource "aws_route_table_association" "primary_subnet_association" {
  subnet_id      = aws_subnet.public_subnet[0].id
  route_table_id = aws_route_table.ecs_route_table.id
}

resource "aws_route_table_association" "secondary_subnet_association" {
  subnet_id      = aws_subnet.public_subnet[1].id
  route_table_id = aws_route_table.ecs_route_table.id
}

resource "aws_subnet" "private_subnet_1" {
  count = 2

  vpc_id                  = aws_vpc.coderco_vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet_${count.index}"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.coderco_vpc.id

  tags = {
    Name = "private_rt"
  }
}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1[0].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_1[1].id
  route_table_id = aws_route_table.private_route_table.id
}

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
  cidr_ipv4   = var.cidr_block
}

resource "aws_vpc_security_group_egress_rule" "ecs_all_egress" {
  security_group_id = aws_security_group.ecs_security_group.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_security_group" "rds_security_group" {
  vpc_id = aws_vpc.coderco_vpc.id

  tags = {
    Name = "rds_security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_postgres_from_ecs" {
  security_group_id = aws_security_group.rds_security_group.id

  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.ecs_security_group.id
}

resource "aws_vpc_security_group_egress_rule" "rds_all_egress" {
  security_group_id = aws_security_group.rds_security_group.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
