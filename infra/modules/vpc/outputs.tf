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
