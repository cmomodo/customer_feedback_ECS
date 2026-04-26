output "certificate_arn" {
  value     = data.aws_acm_certificate.coderco_cert.arn
  sensitive = true
}

output "domain_validation_options" {
  value = {}
}
