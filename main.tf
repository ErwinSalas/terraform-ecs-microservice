terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_acm_certificate" "self_signed_cert" {
  private_key      = file("./ssl/server.key")
  certificate_body = file("./ssl/server.crt")
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
  source = "./modules/security-group"
  groups = [var.api_gateway_key, var.auth_service_key, var.auth_db_key, var.external_lb_key, var.internal_lb_key]
  vpc_id = module.vpc.vpc_id
}

module "rules" {
  source        = "./modules/ingress-egress-rules"
  egress_rules  = local.egress_rules
  ingress_rules = local.ingress_rules
  security_groups_ids = {
    "${var.auth_service_key}" = module.security_groups.security_group_ids[var.auth_service_key]
    "${var.api_gateway_key}"  = module.security_groups.security_group_ids[var.api_gateway_key]
    "${var.auth_db_key}"      = module.security_groups.security_group_ids[var.auth_db_key]
    "${var.internal_lb_key}"  = module.security_groups.security_group_ids[var.internal_lb_key]
    "${var.external_lb_key}"  = module.security_groups.security_group_ids[var.external_lb_key]
  }

  source_security_groups_ids = {
    "${var.auth_service_key}" = module.security_groups.security_group_ids[var.internal_lb_key]
    "${var.api_gateway_key}"  = module.security_groups.security_group_ids[var.external_lb_key]
    "${var.auth_db_key}"      = module.security_groups.security_group_ids[var.auth_service_key]
    "${var.internal_lb_key}"  = module.security_groups.security_group_ids[var.api_gateway_key]
    "${var.external_lb_key}"  = null
  }
}


module "auth_database" {
  source          = "./modules/rds"
  username        = "auth_service"
  password        = "!ExSxExSx020821!"
  private_subnets = module.vpc.private_subnets
  security_groups_ids = [
    module.security_groups.security_group_ids[var.auth_db_key],
    module.security_groups.security_group_ids[var.auth_service_key]
  ]
}

# module "route53_private_zone" {
#   source            = "./modules/route53"
#   internal_url_name = var.internal_url_name
#   alb               = module.internal_alb.internal_alb
#   vpc_id            = module.vpc.vpc_id
# }

module "internal_alb" {
  source            = "./modules/alb"
  name              = "${lower(var.app_name)}-internal-alb"
  subnets           = module.vpc.private_subnets
  vpc_id            = module.vpc.vpc_id
  target_groups     = local.internal_alb_target_groups
  internal          = true
  listener_port     = 443
  listener_protocol = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  acm_arn           = aws_acm_certificate.self_signed_cert.arn
  listeners         = var.internal_alb_config.listeners
  security_groups   = [module.security_groups.security_group_ids[var.internal_lb_key]]
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
  security_groups   = [module.security_groups.security_group_ids[var.external_lb_key]]
}


module "ecs" {
  source                      = "./modules/ecs"
  app_name                    = var.app_name
  app_services                = var.app_services
  account                     = var.account
  region                      = var.region
  service_config              = local.microservice_config
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  public_subnets              = module.vpc.public_subnets
  internal_alb_target_groups  = module.internal_alb.target_groups
  public_alb_target_groups    = module.public_alb.target_groups
  security_groups = {
    "${var.api_gateway_key}"  = module.security_groups.security_group_ids[var.api_gateway_key],
    "${var.auth_service_key}" = module.security_groups.security_group_ids[var.auth_service_key],
  }

  envs = {
    "${var.api_gateway_key}" = [
      {
        name  = "PORT"
        value = ":3000"
      },
      {
        name  = "AUTH_SVC_URL"
        value = "${module.internal_alb.alb-dns}:443"
      },
      {
        name  = "PRODUCT_SVC_URL"
        value = ""
      },
      {
        name  = "ORDER_SVC_URL"
        value = ""
      },
      {
        name  = "AWS_ACCESS_KEY_ID"
        value = local.aws_keys.aws_access_key
      },
      {
        name  = "AWS_SECRET_ACCESS_KEY"
        value = local.aws_keys.aws_secret_key
      },
      {
        name  = "ARN"
        value = aws_acm_certificate.self_signed_cert.arn
      },
    ]
    "${var.auth_service_key}" = [
      {
        name  = "DB_URL"
        value = module.auth_database.db_url
      }
      , {
        name  = "JWT_SECRET_KEY"
        value = "r43t18sc"
      }
      , {
        name  = "API_SECRET"
        value = "98hbun98h"
      },
      {
        name  = "AWS_ACCESS_KEY_ID"
        value = local.aws_keys.aws_access_key
      },
      {
        name  = "AWS_SECRET_ACCESS_KEY"
        value = local.aws_keys.aws_secret_key
      },
      {
        name  = "ARN"
        value = aws_acm_certificate.self_signed_cert.arn
      },
    ]

  }
}