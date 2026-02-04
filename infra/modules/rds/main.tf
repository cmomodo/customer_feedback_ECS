resource "aws_db_instance" "default" {

  depends_on             = [aws_db_subnet_group.default]
  identifier             = "fider-db"
  allocated_storage      = 20
  db_name                = var.db_name
  engine                 = "postgres"
  engine_version         = "17.6"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.postgres17"
  skip_final_snapshot    = true
  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  publicly_accessible    = false

}

#subnet group
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}
