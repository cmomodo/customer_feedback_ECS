output "coderco_vpc" {
  value = aws_vpc.coderco_vpc.id
}

output "ecs_security_group" {
  value = aws_security_group.ecs_security_group.id
}

output "rds_security_group" {
  value = aws_security_group.rds_security_group.id
}

output "primary_subnet_id" {
  value = aws_subnet.public_subnet[0].id
}

output "secondary_subnet_id" {
  value = aws_subnet.public_subnet[1].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet_1[*].id
}
