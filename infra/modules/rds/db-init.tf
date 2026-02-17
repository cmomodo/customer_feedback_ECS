# Task definition to create the fider database
resource "aws_ecs_task_definition" "create_db" {
  family                   = "fider-create-db"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_task_execution_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "create-db"
      image     = "postgres:17"
      essential = true
      command = [
        "psql",
        "postgres://${var.db_username}:${var.db_password}@${aws_db_instance.default.address}:5432/postgres",
        "-c",
        "CREATE DATABASE fider;"
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/fider-create-db"
          "awslogs-create-group"  = "true"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}
