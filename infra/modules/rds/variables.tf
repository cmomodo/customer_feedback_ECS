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

variable "db_identifier" {
  description = "RDS instance identifier"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN used for DB init task"
  type        = string
}

variable "public_accessible" {
  description = "Whether the RDS instance should be publicly accessible"
  type        = bool
  default     = false
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "17.6"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}
