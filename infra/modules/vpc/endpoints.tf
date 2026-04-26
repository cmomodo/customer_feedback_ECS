resource "aws_security_group" "vpc_endpoints" {
  vpc_id = aws_vpc.coderco_vpc.id
  tags   = { Name = "vpc-endpoints-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "endpoints_https" {
  security_group_id = aws_security_group.vpc_endpoints.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = var.cidr_block
}

resource "aws_vpc_security_group_egress_rule" "endpoints_all" {
  security_group_id = aws_security_group.vpc_endpoints.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

locals {
  interface_endpoints = [
    "com.amazonaws.us-east-1.secretsmanager",
    "com.amazonaws.us-east-1.ecr.api",
    "com.amazonaws.us-east-1.ecr.dkr",
    "com.amazonaws.us-east-1.logs",
  ]
}

resource "aws_vpc_endpoint" "interface" {
  for_each            = toset(local.interface_endpoints)
  vpc_id              = aws_vpc.coderco_vpc.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.coderco_vpc.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_route_table.id]
}
