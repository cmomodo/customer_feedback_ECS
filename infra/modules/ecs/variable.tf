variable "image_tag" {
  description = "Docker image tag for the ECR repository"
  type        = string
  default     = "latest"
}

variable "ecr_repository_url" {
  description = "ECR repository URL for the application image"
  type        = string
}

variable "base_url" {
  description = "The base URL for the application"
  type        = string
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS service"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ECS service networking"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ALB target group ARN for ECS service"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM role ARN for ECS task execution"
  type        = string
}

variable "task_role_arn" {
  description = "IAM role ARN for ECS task"
  type        = string
}

variable "task_secret_arn" {
  description = "Secrets Manager ARN for task secret"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
}

variable "database_url" {
  description = "Database URL for the app"
  type        = string
}

variable "jwt_secret_name" {
  description = "Secret name for JWT secret env var"
  type        = string
}

variable "email_noreply" {
  description = "From address Fider uses for outgoing email (must be on the SES-verified domain)"
  type        = string
}

variable "ses_region" {
  description = "AWS region where the SES domain identity lives"
  type        = string
}

variable "ses_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the SES IAM user credentials (JSON: access_key_id + secret_access_key). Used so the ECS execution role can read it."
  type        = string
}

variable "ses_access_key_id_value_from" {
  description = "ECS task definition valueFrom string for EMAIL_AWSSES_ACCESS_KEY_ID (e.g. <secret-arn>:access_key_id::)"
  type        = string
}

variable "ses_secret_access_key_value_from" {
  description = "ECS task definition valueFrom string for EMAIL_AWSSES_SECRET_ACCESS_KEY (e.g. <secret-arn>:secret_access_key::)"
  type        = string
  sensitive   = true
}

variable "container_port" {
  description = "Container port for the ECS service (keep in sync with portMappings)"
  type        = number
  default     = 3000
}

variable "force_new_deployment" {
  description = "Force a fresh ECS deployment whenever Terraform updates the service"
  type        = bool
  default     = true
}

# Container definition variable
variable "container_definition" {
  description = "Container definition for the ECS task"
  type = object({
    name      = string
    image     = string
    cpu       = number
    memory    = number
    essential = bool
  })
  default = {
    name           = "fider"
    image          = "449095351082.dkr.ecr.us-east-1.amazonaws.com/fider:1.0.1"
    cpu            = 256
    memory         = 512
    essential      = true
    awslogs-region = "us-east-1"

  }
}

# Full container configuration variable
variable "container_config" {
  description = "Complete container configuration for the ECS task"
  type = object({
    name      = string
    image     = string
    cpu       = number
    memory    = number
    essential = bool
    portMappings = list(object({
      containerPort = number
      protocol      = string
    }))
    environment = list(object({
      name  = string
      value = string
    }))
    logConfiguration = object({
      logDriver = string
      options   = map(string)
    }),
    readonlyRootFilesystem = optional(bool)
    #environment secrets
    secrets = optional(list(object({
      name  = string
      value = string
    })), [])
  })
  default = {
    name                   = "fider"
    image                  = "449095351082.dkr.ecr.us-east-1.amazonaws.com/fider:1.0.1"
    cpu                    = 256
    memory                 = 512
    essential              = true
    readonlyRootFilesystem = false
    portMappings = [
      {
        containerPort = 3000
        protocol      = "tcp"
      }
    ]
    environment = [
      {
        name  = "BASE_URL"
        value = "placeholder"
      },
      {
        name  = "DATABASE_URL"
        value = "postgres://user:password@host:5432/dbname"
      },
      {
        name  = "EMAIL"
        value = "awsses"
      },
      {
        name  = "EMAIL_NOREPLY"
        value = "noreply@yourdomain.com"
      },
      {
        name  = "EMAIL_AWSSES_REGION"
        value = "us-east-1"
      },
      {
        name  = "GO_ENV"
        value = "development"
      },
      {
        name  = "LOG_LEVEL"
        value = "DEBUG"
      },
      {
        name  = "LOG_CONSOLE"
        value = "true"
      },
      {
        name  = "LOG_SQL"
        value = "true"
      },
      {
        name  = "LOG_FILE"
        value = "false"
      },
      {
        name  = "LOG_FILE_OUTPUT"
        value = "logs/output.log"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/my-app"
        "awslogs-stream-prefix" = "coder_ecs"
      }
    }

    #secret
    secrets = []
  }
}

#cpu & variable
variable "operating_system_family" {
  type    = string
  default = "LINUX"
}

variable "cpu_architecture" {
  type    = string
  default = "ARM64" # set to "ARM64" for Graviton
}
#cpu and memory variables
variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}