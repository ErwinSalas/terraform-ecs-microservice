## Application configurations
account      = 000000
region       = "us-east-1"
app_name     = "ecs-demo"
env          = "dev"
app_services = ["api-gateway", "auth-service"]

#VPC configurations
cidr               = "10.10.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnets     = ["10.10.50.0/24", "10.10.51.0/24"]
private_subnets    = ["10.10.0.0/24", "10.10.1.0/24"]

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
    "HTTP" = {
      listener_port     = 80
      listener_protocol = "HTTP"
    }
  }
}

#Friendly url name for internal load balancer DNS
internal_url_name = "service.internal"

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
