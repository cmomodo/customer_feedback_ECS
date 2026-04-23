output "certificate_arn" {
  value = aws_acm_certificate.coderco_cert.arn
}

output "domain_validation_options" {
  value = {
    for dvo in aws_acm_certificate.coderco_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
}
