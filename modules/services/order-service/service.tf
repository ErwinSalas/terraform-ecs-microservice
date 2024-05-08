resource "aws_ecs_task_definition" "order" {
  family                   = "order-app-task"
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
          name  = "DB_URL"
          value = "postgres://${aws_db_instance.order_db.username}:${aws_db_instance.order_db.password}@${aws_db_instance.order_db.endpoint}/order_db"

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

resource "aws_ecs_service" "order_service" {
  name            = "order-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.order.arn
  desired_count   = var.replicas
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_task_order_sg.id]
    subnets          = var.private_subnets
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.order_discovery_service.arn
  }
}

resource "aws_service_discovery_service" "order_discovery_service" {
  name = "order-service"

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