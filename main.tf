module "infraestructure" {
  source                        = "./modules/infraestructure"
  fargate_cpu                   = 1024
  fargate_memory                = 2048
  health_check_path             = "/health"
  ecs_auto_scale_role_name      = var.ecs_auto_scale_role_name
  ec2_task_execution_role_name  = var.ec2_task_execution_role_name
  aws_region                    = var.aws_region
  az_count                      = var.az_count
  target_app_port               = 3000
  fargate_private_dns_namespace = var.fargate_private_dns_namespace
}


module "api" {
  source            = "./modules/services/api-gateway"
  replicas          = 3
  app_image         = "erwinsalas42/go-grpc-api-gateway:d02dc481e907121a84e6835d6d517fd67446db0b"
  container_name    = "api-app"
  app_port          = 3000
  cpu               = 1024
  memory            = 2048
  health_check_path = "/health"
  auth_service_url  =   "${module.auth.fargate_auth_namespace}.${var.fargate_private_dns_namespace}.local"
  ecs_cluster_id        = module.infraestructure.ecs_cluster_id
  task_execution_role   = module.infraestructure.task_execution_role_arn
  auto_scale_role       = module.infraestructure.auto_scale_role_arn
  aws_region            = var.aws_region
  private_subnets       = module.infraestructure.private_subnets
  target_group_arn      = module.infraestructure.target_group_arn
  alb_sg                = module.infraestructure.alb_sg_id
  vpc_id                = module.infraestructure.vpc_id
  ecs_cluster_name      = module.infraestructure.ecs_cluster_name
  fgms_dns_discovery_id = module.infraestructure.fgms_dns_discovery_id
  depends_on            = [module.infraestructure, module.auth]
}

module "auth" {
  source                = "./modules/services/auth-service"
  replicas              = 3
  app_image             = "erwinsalas42/go-grpc-auth-svc:c3a552a0d20567e9898a6ddaf71bb8d60f0658e6"
  app_port              = 50051
  cpu                   = 1024
  memory                = 2048
  container_name        = "auth-app"
  health_check_path     = "/health"
  subnet_ids        = module.infraestructure.private_subnets
  ecs_cluster_id        = module.infraestructure.ecs_cluster_id
  task_execution_role   = module.infraestructure.task_execution_role_arn
  auto_scale_role       = module.infraestructure.auto_scale_role_arn
  aws_region            = var.aws_region
  private_subnets       = module.infraestructure.private_subnets
  target_group_arn      = module.infraestructure.target_group_arn
  alb_sg                = module.infraestructure.alb_sg_id
  vpc_id                = module.infraestructure.vpc_id
  ecs_cluster_name      = module.infraestructure.ecs_cluster_name
  fgms_dns_discovery_id = module.infraestructure.fgms_dns_discovery_id
  depends_on            = [module.infraestructure]
}

# module "orders" {
#   source  = "./modules/services/product-service"
#   replicas   = 3
#   app_image = "erwinsalas42/go-grpc-order-svc:c5beac14be26667a1e5f7bd6e3fdb0db047444b0"
#   app_port = 50053
#   fargate_cpu = 1024
#   fargate_memory = 2048
#   health_check_path = "/"
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
