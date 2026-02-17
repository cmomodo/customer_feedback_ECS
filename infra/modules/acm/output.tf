output "certificate_arn" {
  value = aws_acm_certificate.coderco_cert.arn
}

#the output for route53 zone id
output "route53_zone_id" {
  value     = data.aws_route53_zone.primary.zone_id
  sensitive = true
}
