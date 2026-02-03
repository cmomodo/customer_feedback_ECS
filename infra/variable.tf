variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag for the ECR repository"
  type        = string
  default     = "1.0.1"
}

variable "base_url" {
  description = "The base URL for the application"
  type        = string
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
    #environment secrets
    secrets = optional(list(object({
      name  = string
      value = string
    })), [])
  })
  default = {
    name      = "fider"
    image     = "449095351082.dkr.ecr.us-east-1.amazonaws.com/fider:1.0.1"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [
      {
        containerPort = 3000
        protocol      = "tcp"
      }
    ]
    environment = [

      {
        name  = "DATABASE_URL"
        value = "postgres://user:password@host:5432/dbname"
      },
      {
        name  = "EMAIL_NOREPLY"
        value = "noreply@yourdomain.com"
      },
      {
        name  = "EMAIL_SMTP_HOST"
        value = "localhost"
      },
      {
        name  = "EMAIL_SMTP_PORT"
        value = "1025"
      },
      {
        name  = "EMAIL_SMTP_USERNAME"
        value = "testuser"
      },
      {
        name  = "EMAIL_SMTP_PASSWORD"
        value = "testpass"
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
