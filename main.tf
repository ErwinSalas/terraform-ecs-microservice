terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

module "iam" {
  source   = "./modules/iam"
  app_name = var.app_name
}

module "vpc" {
  source             = "./modules/vpc"
  app_name           = var.app_name
  env                = var.env
  cidr               = var.cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
  az_count           = var.az_count
}

module "security_groups" {
  source        = "./modules/sg"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = local.ingress_rules
}


module "databases" {
  source          = "./modules/rds"
  private_subnets = module.vpc.private_subnets
  db_config = local.db_config
  security_groups_ids = module.security_groups.security_group_ids
}

module "public_alb" {
  source            = "./modules/alb"
  name              = "${lower(var.app_name)}-public-alb"
  subnets           = module.vpc.public_subnets
  vpc_id            = module.vpc.vpc_id
  target_groups     = local.public_alb_target_groups
  internal          = false
  listener_port     = 80
  listener_protocol = "HTTP"
  ssl_policy        = null
  acm_arn           = null
  listeners         = var.public_alb_config.listeners
  security_groups   = module.security_groups.security_group_ids[var.external_lb_key]
}


module "ecs" {
  source                      = "./modules/ecs"
  app_name                    = var.app_name
  app_services                = var.app_services
  account                     = var.account
  region                      = var.region
  namespace                   = var.namespace
  service_config              = local.microservice_config
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  public_alb_target_groups    = module.public_alb.target_groups
  security_groups = {
    "${var.api_gateway_key}"  = module.security_groups.security_group_ids[var.api_gateway_key],
    "${var.auth_service_key}" = module.security_groups.security_group_ids[var.auth_service_key],
    "${var.order_service_key}" = module.security_groups.security_group_ids[var.order_service_key],
    "${var.product_service_key}" = module.security_groups.security_group_ids[var.product_service_key],
  }

  envs = {
    "${var.api_gateway_key}" = [
      {
        name  = "PORT"
        value = ":3000"
      },
      {
        name  = "AUTH_SVC_URL"
        value = "auth-service.ecs.local:50051"
      },
      {
        name  = "PRODUCT_SVC_URL"
        value = "products-service.ecs.local:50052"
      },
      {
        name  = "ORDER_SVC_URL"
        value = "orders-service.ecs.local:50053"
      },
    ]
    "${var.auth_service_key}" = [
      {
        name  = "DB_URL"
        value = module.databases.db_urls["${var.auth_service_key}"]
      }
      , {
        name  = "JWT_SECRET_KEY"
        value = "r43t18sc"
      }
      , {
        name  = "API_SECRET"
        value = "98hbun98h"
      },
    ]
    "${var.order_service_key}" = [
      {
        name  = "DB_URL"
        value = module.databases.db_urls["${var.order_service_key}"]
      },
      {
        name  = "PRODUCT_SVC_URL"
        value = "products-service.ecs.local:50052"
      },
    ]
     "${var.product_service_key}" = [
      {
        name  = "DB_URL"
        value = module.databases.db_urls["${var.product_service_key}"]
      },
     ]
  }
}