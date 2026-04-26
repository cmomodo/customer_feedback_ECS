#create a new RDS instance
resource "aws_db_instance" "default" {
  depends_on           = [aws_db_subnet_group.default]
  identifier           = var.db_identifier
  allocated_storage    = 20
  db_name              = var.db_name
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres17"
  skip_final_snapshot  = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : coalesce(
    var.final_snapshot_identifier,
    "${var.db_identifier}-final-snapshot"
  )
  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  publicly_accessible    = var.public_accessible

  #multi-aavailability_zone =
  multi_az = true

  #performance insights added
  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 0

}

#subnet group
resource "aws_db_subnet_group" "default" {
  name       = "main-v2"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}
