#import the cloudfront module
module "cloudfront" {
  source          = "./modules/cloudfront"
  domain_name     = var.domain_name
  alb_arn         = module.alb.alb_arn
  alb_dns_name    = module.alb.alb_dns_name
  certificate_arn = module.acm.certificate_arn
}

