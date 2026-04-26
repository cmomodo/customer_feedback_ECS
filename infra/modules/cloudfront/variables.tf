variable "domain_name" {
  description = "Custom domain name served by CloudFront"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the ALB used as the CloudFront VPC origin"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB used as the CloudFront origin"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN attached to the CloudFront distribution"
  type        = string
}
