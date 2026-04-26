#output for ecs task execution role arn
output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

#output for ecs task execution role name
output "ecs_task_execution_role_name" {
  value = aws_iam_role.ecs_task_execution_role.name
}

#log group name=
output "log_group_name" {
  value = aws_cloudwatch_log_group.app.name
}
#output for oidc
output "github_oidc_role_arn" {
  value = data.aws_iam_role.github_oidc.arn
  sensitive = true
}
