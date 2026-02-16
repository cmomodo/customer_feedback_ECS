#resource creation
resource "aws_secretsmanager_secret" "db_encrypt" {
  description = "This will encrypt the database password and username"
  name        = "database-encryption-v3"
}

#resource manager rotation
resource "aws_secretsmanager_secret_version" "db_encrypt" {
  secret_id = aws_secretsmanager_secret.db_encrypt.id
  secret_string = jsonencode({
    username      = var.db_username
    password      = var.db_password
    db_name       = var.db_name
    db_identifier = var.db_identifier
  })
}

resource "aws_secretsmanager_secret" "task_encrypt" {
  description = "This will be used for the task definition used for the ECS"

  name = "task_encryption-v3"
}

#resource manager rotation
resource "aws_secretsmanager_secret_version" "task_encrypt" {
  secret_id = aws_secretsmanager_secret.task_encrypt.id
  secret_string = jsonencode({
    name  = "JWT_SECRET"
    value = var.jwt_secret
  })
}



#resource for identifier encryption
resource "aws_secretsmanager_secret" "identifier" {
  description = "This will encrypt the identifier"
  name        = "identifier-encryption-v3"
}

#resource manager rotation
resource "aws_secretsmanager_secret_version" "identifier" {
  secret_id = aws_secretsmanager_secret.identifier.id
  secret_string = jsonencode({
    username = var.identifier_username
    password = var.identifier_password
  })
}
