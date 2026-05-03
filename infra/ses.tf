#ses email identity for fider
resource "aws_ses_email_identity" "fider_email" {
  email = "fider@${var.domain_name}"
}