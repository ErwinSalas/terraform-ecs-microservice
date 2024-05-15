module "infraestructure" {
  source                       = "./modules/infraestructure"
  fargate_cpu                  = var.fargate_cpu
  fargate_memory               = var.fargate_memory
  health_check_path            = "/health"
  ecs_auto_scale_role_name     = var.ecs_auto_scale_role_name
  ec2_task_execution_role_name = var.ec2_task_execution_role_name
  aws_region                   = var.aws_region
  az_count                     = var.az_count
  target_app_port              = 3000
  fargate_private_dns_namespace = var.fargate_private_dns_namespace
}


module "api" {
  source              = "./modules/services/api-gateway"
  replicas            = 1
  app_image           = "erwinsalas42/go-grpc-api-gateway:5b6a38fe3f3fa1a3a640dec098dcfacfbf1eff3f"
  container_name      = "api-app"
  app_port            = 3000
  cpu                 = var.fargate_cpu
  memory              = var.fargate_memory
  health_check_path   = "/health"
  auth_service_url    = "cloudmap://auth-service.${var.fargate_private_dns_namespace}"
  order_service_url   = "cloudmap://${var.fargate_private_dns_namespace}"
  ecs_cluster_id      = module.infraestructure.ecs_cluster_id
  task_execution_role = module.infraestructure.task_execution_role_arn
  auto_scale_role     = module.infraestructure.auto_scale_role_arn
  aws_region          = var.aws_region
  private_subnets     = module.infraestructure.private_subnets
  target_group_arn    = module.infraestructure.target_group_arn
  alb_sg              = module.infraestructure.alb_sg_id
  vpc_id              = module.infraestructure.vpc_id
  ecs_cluster_name    = module.infraestructure.ecs_cluster_name
  fgms_dns_discovery_id = module.infraestructure.fgms_dns_discovery_id
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
}

module "auth" {
  source              = "./modules/services/auth-service"
  replicas            = 1
  app_image           = "erwinsalas42/go-grpc-auth-svc:7a3d9983eaa3f693a01210bf761afc5ac5e17dfc"
  app_port            = 50051
  cpu                 = var.fargate_cpu
  memory              = var.fargate_memory
  container_name      = "auth-app"
  health_check_path   = "/health"
  ecs_cluster_id      = module.infraestructure.ecs_cluster_id
  task_execution_role = module.infraestructure.task_execution_role_arn
  auto_scale_role     = module.infraestructure.auto_scale_role_arn
  aws_region          = var.aws_region
  private_subnets     = module.infraestructure.private_subnets
  vpc_id              = module.infraestructure.vpc_id
  api_sg             = module.api.api_sg
  ecs_cluster_name = module.infraestructure.ecs_cluster_name
  fgms_dns_discovery_id = module.infraestructure.fgms_dns_discovery_id
   aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
}

# module "orders" {
#   source              = "./modules/services/order-service"
#   replicas            = 1
#   app_image           = "erwinsalas42/go-grpc-order-svc:c5beac14be26667a1e5f7bd6e3fdb0db047444b0"
#   app_port            = 50053
#   cpu                 = var.fargate_cpu
#   memory              = var.fargate_memory
#   health_check_path   = "/"
#   container_name      = "order-app"
#   subnet_ids          = module.infraestructure.private_subnets
#   ecs_cluster_id      = module.infraestructure.ecs_cluster_id
#   task_execution_role = module.infraestructure.task_execution_role_arn
#   auto_scale_role     = module.infraestructure.auto_scale_role_arn
#   aws_region          = var.aws_region
#   private_subnets     = module.infraestructure.private_subnets
#   target_group_arn    = module.infraestructure.order_target_group_arn
#   vpc_id              = module.infraestructure.vpc_id
#   ecs_cluster_name    = module.infraestructure.ecs_cluster_name
#   api_sg             = module.api.api_sg
#   fgms_dns_discovery_id = module.infraestructure.fgms_dns_discovery_id
#   depends_on = [module.infraestructure]
# }

# module "products" {
#   source     = "./modules/services/product-service"
#   replicas   = 3
#   app_image = "erwinsalas42/go-grpc-product-svc:befa435a3cfd70dda6f108905a008932eaa63990"
#   app_port = 50054
#   fargate_cpu = 1024
#   fargate_memory = 2048
#   health_check_path = "/"
# }
