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
  depends_on      = [aws_iam_role_policy.foo]

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
      name      = "fider"
      image     = "449095351082.dkr.ecr.us-east-1.amazonaws.com/fider:1.0.1"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ],
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
          value = "http://fider-alb-1279660236.us-east-1.elb.amazonaws.com"
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
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-stream-prefix" = "coder_ecs"
        }
      }
    }
  ])
}
