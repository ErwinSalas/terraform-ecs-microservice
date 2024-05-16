

account      = 000000
region       = "us-east-1"
app_name     = "ecs-demo"
env          = "dev"
app_services = ["api-gateway-key", "auth-service-key"]

#VPC configurations
cidr               = "10.0.0.0/16"
public_subnets     = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnets    = ["10.0.2.0/24", "10.0.3.0/24", ]
availability_zones = ["us-east-1a", "us-east-1b"]
az_count           = 2

########################################################################################################################
# Map Keys

auth_service_key = "auth-service-key"
auth_db_key      = "auth-db-key"
api_gateway_key  = "api-gateway-key"
internal_lb_key  = "internal-lb-key"
external_lb_key  = "external-lb-key"

#Internal ALB configurations
internal_alb_config = {
  name = "Internal-Alb"
  listeners = {
    "HTTPS" = {
      listener_port     = 443
      listener_protocol = "HTTPS"
    }
  }
}

#Friendly url name for internal load balancer DNS
internal_url_name = "ecs-fargate.com"

#Public ALB configurations
public_alb_config = {
  name = "Public-Alb"
  listeners = {
    "HTTP" = {
      listener_port     = 80
      listener_protocol = "HTTP"
    }
  }
}
