#encode the secret
locals {
  db_creds      = jsondecode(aws_secretsmanager_secret_version.db_encrypt.secret_string)
  db_username   = local.db_creds["username"]
  db_password   = local.db_creds["password"]
  db_name       = local.db_creds["db_name"]
  db_identifier = local.db_creds["db_identifier"]
}

#encode for task encryption
locals {
  task_creds       = jsondecode(aws_secretsmanager_secret_version.task_encrypt.secret_string)
  jwt_secret_name  = local.task_creds["name"]
  jwt_secret_value = local.task_creds["value"]
}

#encode the secret for the identifier
locals {
  identifier_creds = jsondecode(aws_secretsmanager_secret_version.identifier.secret_string)
  identifier_name  = local.identifier_creds["username"]
  identifier_value = local.identifier_creds["password"]
}
