output "aws_cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.ecs_cw_log_group
}

output "aws_ecs_task_definition" {
  value = [for taskdef in aws_ecs_task_definition.ecs_task_definition : taskdef]
}