# 1. DKIM tokens — three CNAMEs SES needs in Route53
resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "aws_route53_record" "ses_dkim" {
  count   = 3
  zone_id = data.aws_route53_zone.ses.zone_id
  name    = "${aws_ses_domain_dkim.main.dkim_tokens[count.index]}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = 600
  records = ["${aws_ses_domain_dkim.main.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

# 2. Block until SES has actually verified the domain (waits on the DKIM CNAMEs above)
resource "aws_ses_domain_identity_verification" "main" {
  domain     = aws_ses_domain_identity.main.id
  depends_on = [aws_route53_record.ses_dkim]
}

# 3. Sandbox recipient verification.
resource "aws_ses_email_identity" "sandbox_recipients" {
  for_each = toset(var.ses_sandbox_verified_recipients)
  email    = each.value
}

# 4. IAM user dedicated to SES sending. Fider's awsses.go uses static creds, so
resource "aws_iam_user" "ses_sender" {
  name = "fider-ses-sender"
  path = "/service/"
  tags = {
    Name = "fider-ses-sender"
  }
}


#Store the access key + secret in Secrets Manager as JSON.
resource "aws_secretsmanager_secret" "ses_credentials" {
  name                    = "fider-ses-credentials-v1"
  description             = "SES IAM user access key + secret for Fider outgoing email"
  recovery_window_in_days = 0
}

#secrets manager rotation
resource "aws_secretsmanager_secret_version" "ses_credentials" {
  secret_id = aws_secretsmanager_secret.ses_credentials.id
  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.ses_sender.id
    secret_access_key = aws_iam_access_key.ses_sender.secret
  })
}



output "ses_domain_identity_arn" {
  value     = aws_ses_domain_identity.main.arn
  sensitive = true
}

output "ses_credentials_secret_arn" {
  value     = aws_secretsmanager_secret.ses_credentials.arn
  sensitive = true
}

# valueFrom strings ECS task definitions can use directly for a JSON-encoded secret
output "ses_access_key_id_value_from" {
  value     = "${aws_secretsmanager_secret.ses_credentials.arn}:access_key_id::"
  sensitive = true
}

output "ses_secret_access_key_value_from" {
  value     = "${aws_secretsmanager_secret.ses_credentials.arn}:secret_access_key::"
  sensitive = true
}
