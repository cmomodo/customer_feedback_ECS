resource "aws_acm_certificate" "cert" {
  domain_name       = "ceedev.co.uk"
  validation_method = "DNS"

  tags = {
    Environment = "test_ecs"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_certificate" "certi" {
  listener_arn    = aws_lb_listener.coderco_alb.arn
  certificate_arn = aws_acm_certificate.cert.arn
}
