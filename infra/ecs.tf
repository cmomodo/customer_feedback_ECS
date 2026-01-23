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
  iam_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  depends_on      = [aws_iam_role_policy.ecs_task_execution_role_policy]

  launch_type = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.default.arn
    container_name   = "fider"
    container_port   = 3000
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [\"us-west-2a\", \"us-west-2b\"]"
  }
}

#task definition
resource "aws_ecs_task_definition" "task_fider" {
  family = "service"
  container_definitions = jsonencode([
    {
      name         = var.container_config.name
      image        = var.container_config.image
      cpu          = var.container_config.cpu
      memory       = var.container_config.memory
      essential    = var.container_config.essential
      portMappings = var.container_config.portMappings
      environment  = var.container_config.environment
      logConfiguration = {
        logDriver = var.container_config.logConfiguration.logDriver
        options = merge(
          var.container_config.logConfiguration.options,
          {
            "awslogs-group" = aws_cloudwatch_log_group.app.name
          }
        )
      }
    }
  ])
}
