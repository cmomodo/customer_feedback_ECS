# Create a VPC
resource "aws_vpc" "coderco_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "coderco-vpc"
  }
}

locals {
  private_subnet_keys = keys(var.private_subnet_cidrs)
  private_subnets = {
    for idx, key in local.private_subnet_keys :
    key => {
      cidr_block        = var.private_subnet_cidrs[key]
      availability_zone = var.availability_zones[idx % length(var.availability_zones)]
    }
  }
}

#private subnet with for each
resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id                  = aws_vpc.coderco_vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet_${each.key}"
  }
}

# Internet gateway required for CloudFront VPC Origins (no route added to private subnets)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.coderco_vpc.id

  tags = {
    Name = "coderco-igw"
  }
}

# Private-only route table. No IGW/NAT route - traffic to AWS services flows through VPC endpoints.
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.coderco_vpc.id

  tags = {
    Name = "private_rt"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}

# ALB security group: internal only, reachable from inside the VPC.
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
  cidr_ipv4   = var.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "ecs_https_ingress" {
  security_group_id = aws_security_group.ecs_security_group.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = var.cidr_block
}

# Allow CloudFront VPC Origin to reach the ALB on port 80
resource "aws_vpc_security_group_ingress_rule" "ecs_cloudfront_ingress" {
  security_group_id = aws_security_group.ecs_security_group.id

  ip_protocol    = "tcp"
  from_port      = 80
  to_port        = 80
  prefix_list_id = "pl-3b927c52"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_app_3000_ingress" {
  security_group_id = aws_security_group.ecs_security_group.id

  ip_protocol = "tcp"
  from_port   = 3000
  to_port     = 3000
  cidr_ipv4   = var.cidr_block
}

#resource egrees rule 
resource "aws_vpc_security_group_egress_rule" "ecs_all_egress" {
  security_group_id = aws_security_group.ecs_security_group.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

#rds security group 
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
