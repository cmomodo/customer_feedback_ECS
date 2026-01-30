resource "aws_db_instance" "default" {

  depends_on             = [aws_security_group.rds_security_group]
  identifier             = "fider-db"
  allocated_storage      = 20
  db_name                = "fider"
  engine                 = "postgres"
  engine_version         = "17.6"
  instance_class         = "db.t3.micro"
  username               = local.db_username
  password               = local.db_password
  parameter_group_name   = "default.postgres17"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  publicly_accessible    = false

}

#subnet group
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.primary_subnet.id, aws_subnet.secondary_subnet.id]

  tags = {
    Name = "My DB subnet group"
  }
}

#rds output
output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}
