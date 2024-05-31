locals {
    grpc_service_config = { for service, config in var.service_config : service => config if !config.is_public }
    rest_service_config = { for service, config in var.service_config : service => config if config.is_public }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = lower("${var.app_name}-cluster")
}

// TODO Resolve issue with SPOT instances
# resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
#   cluster_name = aws_ecs_cluster.ecs_cluster.name

#   capacity_providers = ["FARGATE_SPOT"]

#   default_capacity_provider_strategy {
#     capacity_provider = "FARGATE_SPOT"
#     weight            = 1
#   }
# }

resource "aws_cloudwatch_log_group" "ecs_cw_log_group" {
  for_each = var.service_config
  name     = "${each.key}-logs"
}

resource "aws_service_discovery_private_dns_namespace" "sevice_discovery_namespace" {
  name        = var.namespace
  description = "Services Namespace"
  vpc         = var.vpc_id
}
