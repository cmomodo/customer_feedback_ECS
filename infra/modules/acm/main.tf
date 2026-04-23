# SSL Certificate for HTTPS
resource "aws_acm_certificate" "coderco_cert" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  tags = {
    Name = "coderco-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Wait for certificate to be validated
resource "aws_acm_certificate_validation" "coderco_cert" {
  certificate_arn = aws_acm_certificate.coderco_cert.arn
  timeouts {
    create = "5m"
  }
}
