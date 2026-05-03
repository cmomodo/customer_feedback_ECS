output "db_username" {
  value     = local.db_username
  sensitive = true
}

output "db_password" {
  value     = local.db_password
  sensitive = true
}

output "db_name" {
  value     = local.db_name
  sensitive = true
}

output "db_identifier" {
  value = local.db_identifier
}

output "task_secret_arn" {
  value = aws_secretsmanager_secret.task_encrypt.arn
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
  value = local.identifier_name
}

output "identifier_value" {
  value = local.identifier_value
}
