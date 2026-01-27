# Route 53 Zone
data "aws_route53_zone" "primary" {
  name = "ceedev.co.uk"
}

# SSL Certificate for HTTPS
resource "aws_acm_certificate" "coderco_cert" {
  domain_name       = "ceedev.co.uk"
  subject_alternative_names = ["*.ceedev.co.uk"]
  validation_method = "DNS"

  tags = {
    Name = "coderco-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Certificate validation with DNS
resource "aws_route53_record" "coderco_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.coderco_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary.zone_id
}

# Wait for certificate to be validated
resource "aws_acm_certificate_validation" "coderco_cert" {
  certificate_arn           = aws_acm_certificate.coderco_cert.arn
  timeouts {
    create = "5m"
  }
  depends_on = [aws_route53_record.coderco_cert_validation]
}

# A record pointing domain to ALB
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "ceedev.co.uk"
  type    = "A"

  alias {
    name                   = aws_lb.coderco_alb.dns_name
    zone_id                = aws_lb.coderco_alb.zone_id
    evaluate_target_health = true
  }
}
