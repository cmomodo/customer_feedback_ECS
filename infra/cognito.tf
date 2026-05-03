resource "aws_cognito_user_pool" "pool" {
  name = "linkup-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
}

# Hosted UI domain — required for OAuth2 endpoints
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "linkup-auth"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "app" {
  name         = "linkup-app-client"
  user_pool_id = aws_cognito_user_pool.pool.id

  # Must be true so Fider can use the client secret for server-side OAuth
  generate_secret = true

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  callback_urls = ["${var.base_url}/oauth/cognito/callback"]
  logout_urls   = ["${var.base_url}/oauth/cognito/logout"]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
}

# Store the client secret in Secrets Manager
resource "aws_secretsmanager_secret" "cognito_client_secret" {
  name                    = "cognito-client-secret-v1"
  description             = "Cognito app client secret for Fider OAuth2"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "cognito_client_secret" {
  secret_id     = aws_secretsmanager_secret.cognito_client_secret.id
  secret_string = aws_cognito_user_pool_client.app.client_secret
}

locals {
  cognito_base_url = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${data.aws_region.current.region}.amazoncognito.com"
}

data "aws_region" "current" {}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.app.id
}

output "cognito_client_secret_arn" {
  value = aws_secretsmanager_secret.cognito_client_secret.arn
}
