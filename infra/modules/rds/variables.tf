variable "rds_security_group_id" {
  description = "Security group ID for the RDS instance"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "fider"
}

variable "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN used for DB init task"
  type        = string
}
