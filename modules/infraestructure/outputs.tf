
output "alb_hostname" {
  value = "${aws_alb.main.dns_name}:3000"
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "auto_scale_role_arn" {
  value = aws_iam_role.ecs_auto_scale_role.arn
}

output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "target_group_arn" {
  value = aws_alb_target_group.app.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "alb_sg_id" {
  value = aws_security_group.lb.id
}

output "fgms_dns_discovery_id" {
  description = "fgms service discovery id"
  value       = aws_service_discovery_private_dns_namespace.fgms_dns_discovery.id
}