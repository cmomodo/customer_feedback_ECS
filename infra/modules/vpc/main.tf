locals {
  common_tags = var.tags
}

# Create a VPC
resource "aws_vpc" "coderco_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "coderco-vpc"
  })
}

# Internet gateway
resource "aws_internet_gateway" "coderco_igw" {
  vpc_id = aws_vpc.coderco_vpc.id

  tags = merge(local.common_tags, {
    Name = "ecs_internet_gateway"
  })
}

# Public route table (default route to IGW)
resource "aws_route_table" "ecs_route_table" {
  vpc_id = aws_vpc.coderco_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.coderco_igw.id
  }

  tags = merge(local.common_tags, {
    Name = "coderco_rt"
  })
}

# Public subnet 1
resource "aws_subnet" "primary_subnet" {
  vpc_id                  = aws_vpc.coderco_vpc.id
  cidr_block              = var.primary_subnet
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "main_subnet"
  })
}

resource "aws_route_table_association" "primary_subnet_association" {
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.ecs_route_table.id
}

# Public subnet 2
resource "aws_subnet" "secondary_subnet" {
  vpc_id                  = aws_vpc.coderco_vpc.id
  cidr_block              = var.secondary_public_subnet
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "alb_subnet"
  })
}

resource "aws_route_table_association" "secondary_subnet_association" {
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.ecs_route_table.id
}

# Private subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.coderco_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.availability_zones[0]

  tags = merge(local.common_tags, {
    Name = "private_subnet_1"
  })
}

# Private subnet 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.coderco_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.availability_zones[1]

  tags = merge(local.common_tags, {
    Name = "private_subnet_2"
  })
}

# Private route table (no default route to IGW; add NAT/VPC endpoints if needed)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.coderco_vpc.id

  tags = merge(local.common_tags, {
    Name = "private_rt"
  })
}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Security group for ECS / app (basic example)
resource "aws_security_group" "ecs_security_group" {
  name        = "ecs_security_group"
  description = "Security group for ECS tasks/services"
  vpc_id      = aws_vpc.coderco_vpc.id

  ingress {
    description = "HTTP"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port (example)"
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = [var.cidr_block]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "ecs_security_group"
  })
}

# Security group for RDS
resource "aws_security_group" "rds_security_group" {
  name        = "rds_security_group"
  description = "Security group for RDS; allows Postgres from ECS SG"
  vpc_id      = aws_vpc.coderco_vpc.id

  ingress {
    description     = "Postgres from ECS"
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.ecs_security_group.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "rds_security_group"
  })
}
