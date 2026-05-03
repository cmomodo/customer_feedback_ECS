module "acm" {
  source      = "./modules/acm"
  domain_name = var.domain_name
}

module "route53" {
  source                  = "./modules/route53"
  domain_name             = var.domain_name
  cloudfront_domain_name  = module.cloudfront.cloudfront_domain
  cloudfront_zone_id      = module.cloudfront.cloudfront_zone_id
  cert_validation_options = module.acm.domain_validation_options

  depends_on = [module.acm, module.cloudfront]
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
  source = "./modules/vpc"

  cidr_block           = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs

  availability_zones = ["us-east-1a", "us-east-1b"]
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
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.final_snapshot_identifier

  depends_on = [
    module.vpc
  ]
}

module "alb" {
  source            = "./modules/alb"
  security_group_id = module.vpc.ecs_security_group
  container_port    = var.container_port
  subnet_ids        = module.vpc.private_subnet_ids
  vpc_id            = module.vpc.coderco_vpc
  certificate_arn   = module.acm.certificate_arn

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
  database_url       = "postgres://${module.secrets.db_username}:${module.secrets.db_password}@${module.rds.rds_endpoint}/${module.rds.db_name}"
  ecr_repository_url = var.create_ecr_repository ? aws_ecr_repository.app[0].repository_url : data.aws_ecr_repository.app[0].repository_url
}

module "ecs" {
  source             = "./modules/ecs"
  base_url           = var.base_url
  image_tag          = var.image_tag
  ecr_repository_url = local.ecr_repository_url

  ecs_security_group_id = module.vpc.ecs_security_group
  container_port        = var.container_port
  subnet_ids            = module.vpc.private_subnet_ids
  target_group_arn      = module.alb.target_group_arn

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
data "aws_ecr_repository" "app" {
  count = var.create_ecr_repository ? 0 : 1
  name  = var.ecr_repository_name
}
