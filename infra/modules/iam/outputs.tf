output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_execution_role_name" {
  value = aws_iam_role.ecs_task_execution_role.name
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.app.name
}

output "github_oidc_role_arn" {
  value = aws_iam_role.github_oidc.arn
}

output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}
