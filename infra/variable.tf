variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
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
    })
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
        name  = "JWT_SECRET"
        value = "hsjl]W;&ZcHxT&FK;s%bgIQF:#ch=~#Al4:5]N;7V<qPZ3e9lT4'%;go;LIkc%k"
      },
      {
        name  = "DATABASE_URL"
        value = "postgres://fider:Test1234!@fider-db.cjqxkyjn8ujy.us-east-1.rds.amazonaws.com:5432/fider"
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
        name  = "BASE_URL"
        value = "https://ceedev.co.uk"
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
  }
}

variable "aws_db_instance" {
  description = "AWS RDS database instance credentials"
  type = object({
    username = string
    password = string
  })
  default = {
    username = "fider"
    password = "Test1234!"
  }
}
