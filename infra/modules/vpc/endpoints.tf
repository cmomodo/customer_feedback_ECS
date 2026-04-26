data "aws_region" "current" {}

# SG for interface VPC endpoints - only 443 from inside the VPC.
resource "aws_security_group" "vpc_endpoints" {
  vpc_id = aws_vpc.coderco_vpc.id

  tags = {
    Name = "vpc_endpoints_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_https" {
  security_group_id = aws_security_group.vpc_endpoints.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = var.cidr_block
}

resource "aws_vpc_security_group_egress_rule" "vpc_endpoints_all_egress" {
  security_group_id = aws_security_group.vpc_endpoints.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# Gateway endpoint for S3 (ECR image layers live in S3). Gateway endpoints use route tables, not subnets/SGs.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.coderco_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_route_table.id]

  tags = {
    Name = "vpce_s3"
  }
}

# Interface endpoints. Placed in every private subnet for HA; use the endpoint SG.
locals {
  interface_endpoints = {
    ecr_api        = "ecr.api"
    ecr_dkr        = "ecr.dkr"
    logs           = "logs"
    secretsmanager = "secretsmanager"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id              = aws_vpc.coderco_vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.private : s.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "vpce_${each.key}"
  }
}
