module "acm" {
  source      = "./modules/acm"
  domain_name = var.domain_name
}

# A record pointing domain to ALB
resource "aws_route53_record" "main" {
  zone_id = module.acm.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

module "secrets" {
  source = "./modules/secrets"

  db_username         = var.db_username
  db_password         = var.db_password
  db_name             = var.db_name
  db_identifier       = var.db_identifier
  jwt_secret          = var.jwt_secret
  identifier_username = var.identifier_username
  identifier_password = var.identifier_password
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.vpc_cidr

  primary_subnet          = var.primary_subnet_cidr
  secondary_public_subnet = var.secondary_subnet_cidr
  private_subnet_1_cidr   = var.private_subnet_1_cidr
  private_subnet_2_cidr   = var.private_subnet_2_cidr

  availability_zones = ["us-east-1a", "us-east-1b"]
  #use ephemeral for this.
}

module "rds" {
  source                      = "./modules/rds"
  rds_security_group_id       = module.vpc.rds_security_group
  private_subnet_ids          = module.vpc.private_subnet_ids
  db_username                 = module.secrets.db_username
  db_password                 = module.secrets.db_password
  db_name                     = module.secrets.db_name
  db_identifier               = module.secrets.db_identifier
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn

  depends_on = [
    module.vpc
  ]
}

module "alb" {
  source            = "./modules/alb"
  security_group_id = module.vpc.ecs_security_group
  container_port    = var.container_port
  subnet_ids = [
    module.vpc.secondary_subnet_id,
    module.vpc.primary_subnet_id
  ]
  vpc_id          = module.vpc.coderco_vpc
  certificate_arn = module.acm.certificate_arn

  depends_on = [
    module.vpc,
    module.rds
  ]
}

module "iam" {
  source      = "./modules/iam"
  github_repo = var.github_repo
}

locals {
  database_url = "postgres://${module.secrets.db_username}:${module.secrets.db_password}@${module.rds.rds_endpoint}/${module.rds.db_name}"
}

module "ecs" {
  source   = "./modules/ecs"
  base_url = var.base_url

  ecs_security_group_id = module.vpc.ecs_security_group
  container_port        = var.container_port
  subnet_ids = [
    module.vpc.primary_subnet_id,
    module.vpc.secondary_subnet_id
  ]
  target_group_arn = module.alb.target_group_arn

  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_execution_role_arn
  log_group_name     = module.iam.log_group_name

  task_secret_arn = module.secrets.task_secret_arn
  jwt_secret_name = module.secrets.jwt_secret_name
  database_url    = local.database_url

  depends_on = [
    module.iam,
    module.alb,
    module.secrets,
    module.rds
  ]
}

#imported ecr repo
data "aws_ecr_repository" "fider" {
  name = "fider"
}
