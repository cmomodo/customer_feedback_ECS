variable "domain_name" {
  type = string
}

variable "cloudfront_domain_name" {
  type = string
}

variable "cloudfront_zone_id" {
  type = string
}

variable "cert_validation_options" {
  type = map(object({
    name   = string
    record = string
    type   = string
  }))
  default = {}
}
