resource "aws_db_instance" "default" {

  depends_on             = [aws_default_security_group.rds_security_group]
  allocated_storage      = 20
  db_name                = "fider-db"
  engine                 = "postgresql"
  engine_version         = "17.6"
  instance_class         = "db.t3.micro"
  username               = "fider"
  password               = "Test1234!"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_default_security_group.rds_security_group.id]
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
