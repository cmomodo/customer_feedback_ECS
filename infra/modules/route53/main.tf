data "aws_route53_zone" "primary" {
  name = var.domain_name
}

# ACM certificate DNS validation records
resource "aws_route53_record" "cert_validation" {
  for_each = var.cert_validation_options

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary.zone_id
}

# A record pointing domain to CloudFront
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}
