
resource "aws_ecs_task_definition" "api_gateway" {
  family                   = "api-app-task"
  execution_role_arn       = var.task_execution_role
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions = jsonencode([
    {
      name        = var.container_name
      image       = var.app_image
      cpu         = 1024
      memory      = 2048
      networkMode = "awsvpc"
      environment = [
        {
          name  = "PORT"
          value = ":3000"
        },
        {
          name  = "AUTH_SVC_URL"
          value = "${var.auth_service_url}:50051"
        },
        {
          name  = "PRODUCT_SVC_URL"
          value = "product-service.k8s-microservices:82"
        },
        {
          name  = "ORDER_SVC_URL"
          value = "order-service.k8s-microservices:81"
        }

      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/api-app"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "api_gateway_service" {
  name            = "api-gateway-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.api_gateway.arn
  desired_count   = var.replicas
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_task_api_gateway_sg.id]
    subnets          = var.private_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.app_port
  }
}

resource "aws_service_discovery_service" "api_gateway_discovery_service" {
  name = "api"

  dns_config {
    namespace_id = var.fgms_dns_discovery_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 2
  }
}