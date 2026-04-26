#rds output
output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
  sensitive = true
}

#output for db name
output "db_name" {
  value = aws_db_instance.default.db_name
  sensitive = true
}
