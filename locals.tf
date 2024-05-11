
locals {
  microservice_config = {
    "${var.api_gateway_key}" = {
      name           =  "${var.api_gateway_key}"
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
      name           = "${var.auth_service_key}"
      is_public      = false
      image          = "erwinsalas42/go-grpc-auth-svc:c3a552a0d20567e9898a6ddaf71bb8d60f0658e6"
      container_port = 50051
      host_port      = 50051
      cpu            = 256
      memory         = 512
      desired_count  = 1
      alb_target_group = {
        port              = 50051
        protocol          = "TCP"
        path_pattern      = ["/auth*"]
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
  }
}

locals {
  internal_alb_target_groups = { for service, config in local.microservice_config : service => config.alb_target_group if !config.is_public }
  public_alb_target_groups   = { for service, config in local.microservice_config : service => config.alb_target_group if config.is_public }

  ingress_rules = {
    "${var.internal_lb_key}" = [{
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    }]
    "${var.external_lb_key}" = [{
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }]
    "${var.auth_service_key}" = [{
      from_port   = local.microservice_config[var.auth_service_key].host_port
      to_port     = local.microservice_config[var.auth_service_key].host_port
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    }]
    "${var.auth_db_key}" = [{
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    }]
    "${var.api_gateway_key}" = [{
      from_port   = local.microservice_config[var.api_gateway_key].host_port
      to_port     = local.microservice_config[var.api_gateway_key].host_port
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    }]
  }

  egress_rules = {
    "${var.internal_lb_key}" = [{
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }]
    "${var.external_lb_key}" = [{
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }]
    "${var.auth_service_key}" = [{
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }]
    "${var.api_gateway_key}" = [{
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }]
  }
}