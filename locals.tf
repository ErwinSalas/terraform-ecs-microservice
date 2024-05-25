
locals {
  microservice_config = {
    "${var.api_gateway_key}" = {
      name           = "${var.api_gateway_key}"
      is_public      = true
      image          = "erwinsalas42/go-grpc-api-gateway:c7a7debaa2113de6a98202eedf746212564123e4"
      container_port = 3000
      host_port      = 3000
      cpu            = 256
      memory         = 512
      desired_count  = 1

      alb_target_group = {
        port              = 3000
        protocol          = "HTTP"
        path_pattern      = ["/*"]
        health_check_path = "/health"
        priority          = 1
      }
      auto_scaling = {
        max_capacity = 2
        min_capacity = 1
        cpu = {
          target_value = 75
        }
        memory = {
          target_value = 75
        }
      }
    },
    "${var.auth_service_key}" = {
      name             = "${var.auth_service_key}"
      is_public        = false
      image            = "erwinsalas42/go-grpc-auth-svc:a6562e28322fb0666cfef295c436c8f9568b9799"
      container_port   = 50051
      host_port        = 50051
      cpu              = 256
      memory           = 512
      desired_count    = 1
      alb_target_group = null
      auto_scaling = {
        max_capacity = 2
        min_capacity = 1
        cpu = {
          target_value = 75
        }
        memory = {
          target_value = 75
        }
      }
    },
    "${var.order_service_key}" = {
      name             = "${var.order_service_key}"
      is_public        = false
      image            = "erwinsalas42/go-grpc-order-svc:0eab8641d2b599b6374095371bc29397abbf0110"
      container_port   = 50053
      host_port        = 50053
      cpu              = 256
      memory           = 512
      desired_count    = 1
      alb_target_group = null
      auto_scaling = {
        max_capacity = 2
        min_capacity = 1
        cpu = {
          target_value = 75
        }
        memory = {
          target_value = 75
        }
      }
    },
     "${var.product_service_key}" = {
      name             = "${var.product_service_key}"
      is_public        = false
      image            = "erwinsalas42/go-grpc-product-svc:834ffa4e54cf388e9c3971c4922aa1b8ddccec22"
      container_port   = 50052
      host_port        = 50052
      cpu              = 256
      memory           = 512
      desired_count    = 1
      alb_target_group = null
      auto_scaling = {
        max_capacity = 2
        min_capacity = 1
        cpu = {
          target_value = 75
        }
        memory = {
          target_value = 75
        }
      }
    },
  }

  db_config = {
    for service, config in local.microservice_config : service => {
      username        = "${service}user"
      password        = "c7a7debaa2113de6a98202eedf746212564123e4"
      db_name         = "${service}"
      security_group = "${service}-db"
      service = service
    } if config.is_public == false
  }

  public_alb_target_groups = { for service, config in local.microservice_config : service => config.alb_target_group if config.is_public }

  ingress_rules = [
    { name        = "${var.external_lb_key}"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      source_sg   = null
    },
    { name        = "${var.auth_service_key}"
      from_port   = local.microservice_config[var.auth_service_key].host_port
      to_port     = local.microservice_config[var.auth_service_key].host_port
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      source_sg   = var.api_gateway_key
    },
    { name        = "${var.auth_db_key}"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      source_sg   = var.auth_service_key
    },
    { name        = "${var.order_service_key}"
      from_port   = local.microservice_config[var.order_service_key].host_port
      to_port     = local.microservice_config[var.order_service_key].host_port
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      source_sg   = var.api_gateway_key
    },
    { name        = "${var.order_db_key}"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      source_sg   = var.order_service_key
    },
    { name        = "${var.product_service_key}"
      from_port   = local.microservice_config[var.product_service_key].host_port
      to_port     = local.microservice_config[var.product_service_key].host_port
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      source_sg   = var.api_gateway_key
    },
    { name        = "${var.product_service_key}"
      from_port   = local.microservice_config[var.product_service_key].host_port
      to_port     = local.microservice_config[var.product_service_key].host_port
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      source_sg   = var.order_service_key
    },
    { name        = "${var.product_db_key}"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      source_sg   = var.product_service_key
    },
    { name        = "${var.api_gateway_key}"
      from_port   = local.microservice_config[var.api_gateway_key].host_port
      to_port     = local.microservice_config[var.api_gateway_key].host_port
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      source_sg   = var.external_lb_key
    },
  ]
}