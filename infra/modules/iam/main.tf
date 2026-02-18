# GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# GitHub OIDC Role for CI/CD
resource "aws_iam_role" "github_oidc" {
  name = "github_oidc_portfolio"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
        }
      }
    }]
  })
}

# Attach policies for ECR, ECS, and Terraform operations
resource "aws_iam_role_policy" "github_oidc_policy" {
  name = "github-oidc-policy"
  role = aws_iam_role.github_oidc.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:*",
          "ecs:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "rds:*",
          "secretsmanager:*",
          "logs:*",
          "iam:*",
          "acm:*",
          "route53:*",
          "s3:*",
          "dynamodb:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Route 53 specific permissions for GitHub Actions
resource "aws_iam_role_policy" "github_oidc_route53_tags_policy" {
  name = "github-oidc-route53-tags-policy"
  role = aws_iam_role.github_oidc.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ListTagsForResource"
        ]
        Resource = "arn:aws:route53:::hostedzone/*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/my-app"
  retention_in_days = 14
}

#iam role for cloudwatch logs
resource "aws_iam_role_policy" "task_exec_logs" {
  name = "task-exec-logs"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.app.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:us-east-1:449095351082:secret:task_encryption-*"
      }
    ]
  })
}


#to write to ecs_task_execution_role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
