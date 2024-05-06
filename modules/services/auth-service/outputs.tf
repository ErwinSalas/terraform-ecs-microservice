output "fargate_auth_namespace" {
  value = aws_service_discovery_service.auth_discovery_service.name
}