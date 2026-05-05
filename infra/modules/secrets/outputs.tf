output "db_username" {
  value = local.db_username
}

output "db_password" {
  value     = local.db_password
  sensitive = true
}

output "db_name" {
  value = local.db_name
}

output "db_identifier" {
  value     = local.db_identifier
  sensitive = true
}

output "task_secret_arn" {
  value     = aws_secretsmanager_secret.task_encrypt.arn
  sensitive = true
}

output "jwt_secret_name" {
  value     = local.jwt_secret_name
  sensitive = true
}

output "jwt_secret_value" {
  value     = local.jwt_secret_value
  sensitive = true
}

output "identifier_name" {
  value     = local.identifier_name
  sensitive = true
}

output "identifier_value" {
  value     = local.identifier_value
  sensitive = true
}
