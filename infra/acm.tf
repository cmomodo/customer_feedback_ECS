# Route 53 Zone
data "aws_route53_zone" "primary" {
  name = "ceedev.co.uk"
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
