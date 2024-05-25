

account      = 000000
region       = "us-east-1"
app_name     = "ecs-demo"
env          = "dev"
app_services = ["api-gateway", "auth"]

#VPC configurations
cidr               = "10.0.0.0/16"
public_subnets     = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnets    = ["10.0.2.0/24", "10.0.3.0/24", ]
availability_zones = ["us-east-1a", "us-east-1b"]
az_count           = 2

########################################################################################################################
# Map Keys

auth_service_key    = "auth"
auth_db_key         = "auth-db"
order_service_key   = "orders"
order_db_key        = "orders-db"
product_service_key = "products"
product_db_key      = "products-db"
api_gateway_key     = "api-gateway"
external_lb_key     = "external-lb"


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
