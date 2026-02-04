module "rds" {
  source = "./modules/rds"
  rds_security_group_id       = module.vpc.rds_security_group
  private_subnet_ids          = module.vpc.private_subnet_ids
  db_username                 = module.secrets.db_username
  db_password                 = module.secrets.db_password
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
}
