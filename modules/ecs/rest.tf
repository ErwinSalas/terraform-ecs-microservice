
# ECS Task Definitions for REST Microservices
# These tasks perform health checks using HTTP endpoints. 
# The health checks are configured to call specific paths set up for this purpose 
# through the load balancer target group.
resource "aws_ecs_task_definition" "rest_ecs_task_definition" {
  for_each                 = local.rest_service_config
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


#Create services for app services
resource "aws_ecs_service" "rest_service" {
  for_each = local.rest_service_config

  name            = "${each.value.name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.rest_ecs_task_definition[each.key].arn
  desired_count   = each.value.desired_count
  launch_type = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.security_groups[each.key]]
  }

    # In this cloud solution, the REST microservices utilize a public Application Load Balancer (ALB) 
    # to receive and route traffic.
    load_balancer {
      target_group_arn = var.public_alb_target_groups[each.key].arn
      container_name   = each.value.name
      container_port   = each.value.container_port
    }

    # capacity_provider_strategy {
    #   capacity_provider = "FARGATE_SPOT"
    #   weight            = 1
    # }

    # Even though we use an ALB in front of this service, it needs to be registered 
    # in the same namespace as the gRPC service within the service mesh via Service Connect.
    # This is to enable service-to-service communication between gRPC and REST services.
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


resource "aws_appautoscaling_target" "rest_service_autoscaling" {
  for_each           = local.rest_service_config
  max_capacity       = each.value.auto_scaling.max_capacity
  min_capacity       = each.value.auto_scaling.min_capacity
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.rest_service[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "rest_ecs_policy_memory" {
  for_each           = local.rest_service_config
  name               = "${var.app_name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.rest_service_autoscaling[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.rest_service_autoscaling[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.rest_service_autoscaling[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = each.value.auto_scaling.memory.target_value
  }
}

resource "aws_appautoscaling_policy" "rest_ecs_policy_cpu" {
  for_each           = local.rest_service_config
  name               = "${var.app_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.rest_service_autoscaling[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.rest_service_autoscaling[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.rest_service_autoscaling[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = each.value.auto_scaling.cpu.target_value
  }
}