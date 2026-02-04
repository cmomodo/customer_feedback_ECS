module "acm" {
  source = "./modules/acm"

}

# A record pointing domain to ALB
resource "aws_route53_record" "main" {
  zone_id = module.acm.route53_zone_id
  name    = "ceedev.co.uk"
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

module "secrets" {
  source = "./modules/secrets"
}

module "alb" {
  source            = "./modules/alb"
  security_group_id = module.vpc.ecs_security_group
  subnet_ids = [
    module.vpc.secondary_subnet_id,
    module.vpc.primary_subnet_id
  ]
  vpc_id          = module.vpc.coderco_vpc
  certificate_arn = module.acm.certificate_arn
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.20.0.0/16"
  tags = {
    Name = "MyVPC"
  }
  primary_subnet          = var.primary_subnet
  secondary_public_subnet = var.secondary_public_subnet
  private_subnet_1_cidr   = var.private_subnet_1_cidr
  private_subnet_2_cidr   = var.private_subnet_2_cidr
  availability_zones      = ["us-east-1a", "us-east-1b"]
  #use ephemeral for this.
}


module "iam" {
  source = "./modules/iam"

}

#imported ecr repo
data "aws_ecr_repository" "fider" {
  name = "fider"
}
