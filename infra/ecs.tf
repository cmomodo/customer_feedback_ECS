#calling ecs module
locals {
  database_url = "postgres://${module.secrets.db_username}:${module.secrets.db_password}@${module.rds.rds_endpoint}/${module.rds.db_name}"
}

module "ecs" {
  source   = "./modules/ecs"
  base_url = var.base_url

  ecs_security_group_id = module.vpc.ecs_security_group
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
