resource "aws_ecs_cluster" "coder_ecs" {
  name = "customer_feedback"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#service
resource "aws_ecs_service" "coderco_ecs" {
  name            = "runner_one"
  cluster         = aws_ecs_cluster.coder_ecs.id
  task_definition = aws_ecs_task_definition.task_fider.arn
  desired_count   = 1
  depends_on      = [aws_iam_role_policy.task_exec_logs]

  launch_type = "FARGATE"
  network_configuration {
    security_groups  = [aws_security_group.ecs_security_group.id]
    subnets          = [aws_subnet.primary_subnet.id, aws_subnet.secondary_subnet.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.coderco_alb.arn
    container_name   = "fider"
    container_port   = 3000
  }
}

#task definition
resource "aws_ecs_task_definition" "task_fider" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

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
          name      = local.jwt_secret_name
          valueFrom = aws_secretsmanager_secret.task_encrypt.arn
        }
      ])
      environment = var.container_config.environment

      logConfiguration = {
        logDriver = var.container_config.logConfiguration.logDriver
        options = merge(
          var.container_config.logConfiguration.options,
          {
            "awslogs-group"  = aws_cloudwatch_log_group.app.name
            "awslogs-region" = "us-east-1"
          }
        )
      }
    }

  ])
}
