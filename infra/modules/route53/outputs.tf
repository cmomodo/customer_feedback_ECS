output "zone_id" {
  value = data.aws_route53_zone.primary.zone_id
}

output "cert_validation_record_fqdns" {
  value = [for r in aws_route53_record.cert_validation : r.fqdn]
}
