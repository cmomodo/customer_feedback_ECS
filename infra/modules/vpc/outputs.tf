#vpc output
output "coderco_vpc" {
  value = aws_vpc.coderco_vpc.id
}

#ecs security group output
output "ecs_security_group" {
  value = aws_security_group.ecs_security_group.id
}

#rds security group output
output "rds_security_group" {
  value = aws_security_group.rds_security_group.id
}

output "primary_subnet_id" {
  value = aws_subnet.primary_subnet.id
}

output "secondary_subnet_id" {
  value = aws_subnet.secondary_subnet.id
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
    #use count
  ]
}
