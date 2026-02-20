resource "aws_db_instance" "default" {

  depends_on             = [aws_db_subnet_group.default]
  identifier             = var.db_identifier
  allocated_storage      = 20
  db_name                = var.db_name
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.postgres17"
  skip_final_snapshot    = true
  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  publicly_accessible    = var.public_accessible

}

#subnet group
resource "aws_db_subnet_group" "default" {
  name       = "main-v2"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}
