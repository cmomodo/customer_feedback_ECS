#name of the ecs cluster
resource "aws_ecs_cluster" "coder_ecs" {
  name = "customer_feedback"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#name of the service
resource "aws_ecs_service" "coderco_ecs" {
  name            = "runner_one"
  cluster         = aws_ecs_cluster.coder_ecs.id
  task_definition = aws_ecs_task_definition.task_fider.arn
  desired_count   = 1

  #fargate to run the container
  launch_type = "FARGATE"
  network_configuration {
    security_groups  = [var.ecs_security_group_id]
    subnets          = var.subnet_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "fider"
    container_port   = var.container_port
  }
}

#task definition
resource "aws_ecs_task_definition" "task_fider" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name         = var.container_config.name
      image        = var.container_config.image
      cpu          = 256
      memory       = 512
      essential    = var.container_config.essential
      portMappings = var.container_config.portMappings
      secrets = concat(var.container_config.secrets, [
        {
          name      = var.jwt_secret_name
          valueFrom = var.task_secret_arn
        }
      ])
      environment = [
        for env in var.container_config.environment :
        env.name == "BASE_URL" ? { name = "BASE_URL", value = var.base_url } :
        env.name == "DATABASE_URL" ? { name = "DATABASE_URL", value = var.database_url } : env
      ]

      logConfiguration = {
        logDriver = var.container_config.logConfiguration.logDriver
        options = merge(
          var.container_config.logConfiguration.options,
          {
            "awslogs-group"  = var.log_group_name
            "awslogs-region" = "us-east-1"
          }
        )
      }
    }

  ])
}
