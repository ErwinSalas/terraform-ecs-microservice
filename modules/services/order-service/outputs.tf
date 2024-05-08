output "fargate_order_namespace" {
  value = aws_service_discovery_service.order_discovery_service.name
}