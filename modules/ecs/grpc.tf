
# ECS Task Definitions for gRPC microservices
# These tasks include grpcurl in their images to facilitate container health checks 
# by calling the grpc.health.v1.Health/Check endpoint.
resource "aws_ecs_task_definition" "grpc_ecs_task_definition" {
  for_each                 = local.grpc_service_config
  family                   = "${lower(var.app_name)}-${each.key}"
  execution_role_arn       = var.ecs_task_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = each.value.memory
  cpu                      = each.value.cpu

  container_definitions = jsonencode([
    {
      name      = each.value.name
      image     = each.value.image
      cpu       = each.value.cpu
      memory    = each.value.memory
      essential = true
      environment = var.envs[each.key]
      portMappings = [
        {
          name = each.key
          containerPort = each.value.container_port
          hostPort : each.value.host_port
        }
      ]
      healthCheck = {
      command     = [
        "grpcurl",
        "-plaintext",
        "-d",
        "{\"service\": \"\"}",
        "localhost:${each.value.container_port}",
        "grpc.health.v1.Health/Check"
      ]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }

      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-group         = "${each.key}-logs"
          awslogs-region        = var.region
          awslogs-stream-prefix = var.app_name
        }
      }
    }
  ])
}


# ECS Services for gRPC microservices
# These services use AWS Service Connect for simplified inter-service communication 
# and do not require load balancer association.
resource "aws_ecs_service" "grpc_service" {
  for_each = local.grpc_service_config

  name            = "${each.value.name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.grpc_ecs_task_definition[each.key].arn
  launch_type     = "FARGATE"
  desired_count   = each.value.desired_count

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.security_groups[each.key]]
  }

  # AWS Service Connect configuration for inter-service communication
  service_connect_configuration {
    enabled = true
    namespace =  aws_service_discovery_private_dns_namespace.sevice_discovery_namespace.arn
    service {
        client_alias {
          dns_name = "${each.value.name}-service.${var.namespace}"
          port = "${each.value.container_port}"
        }
      port_name       = each.key
      discovery_name  =  "${each.value.name}-service"
    }
  }
}


resource "aws_appautoscaling_target" "grpc_service_autoscaling" {
  for_each           = local.grpc_service_config
  max_capacity       = each.value.auto_scaling.max_capacity
  min_capacity       = each.value.auto_scaling.min_capacity
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.grpc_service[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "grpc_ecs_policy_memory" {
  for_each           = local.grpc_service_config
  name               = "${var.app_name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grpc_service_autoscaling[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.grpc_service_autoscaling[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.grpc_service_autoscaling[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = each.value.auto_scaling.memory.target_value
  }
}

resource "aws_appautoscaling_policy" "grpc_ecs_policy_cpu" {
  for_each           = local.grpc_service_config
  name               = "${var.app_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grpc_service_autoscaling[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.grpc_service_autoscaling[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.grpc_service_autoscaling[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = each.value.auto_scaling.cpu.target_value
  }
}