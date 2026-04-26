output "coderco_vpc" {
  value = aws_vpc.coderco_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.coderco_vpc.cidr_block
}

output "ecs_security_group" {
  value = aws_security_group.ecs_security_group.id
}

output "rds_security_group" {
  value = aws_security_group.rds_security_group.id
}

output "private_subnet_ids" {
  value = values(aws_subnet.private)[*].id
}
