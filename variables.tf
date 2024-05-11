########################################################################################################################
# Application
variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "account" {
  type        = number
  description = "AWS account number"
}

variable "region" {
  type        = string
  description = "region"
}


variable "app_name" {
  type        = string
  description = "Application name"
}

variable "app_services" {
  type        = list(string)
  description = "service name list"
}

variable "env" {
  type        = string
  description = "Environment"
}

########################################################################################################################
# Map Keys

variable "auth_service_key" {
  type = string
}

variable "auth_db_key" {
  type = string
}

variable "api_gateway_key" {
  type = string
}

variable "internal_lb_key" {
  type = string
}

variable "external_lb_key" {
  type = string
}


########################################################################################################################

# VPC
variable "cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones that the services are running"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets"
}

variable "az_count" {
  type        = number
  description = "Availability zones that the services are running"
}

########################################################################################################################
#ALB

variable "internal_alb_config" {
  type = object({
    name = string
    listeners = map(object({
      listener_port     = number
      listener_protocol = string
    }))
  })
  description = "Internal ALB configuration"
}

variable "internal_url_name" {
  type        = string
  description = "Friendly url name for the internal load balancer DNS"
}

variable "public_alb_config" {
  type = object({
    name = string
    listeners = map(object({
      listener_port     = number
      listener_protocol = string
    }))
  })
  description = "Public ALB configuration"
}

########################################################################################################################
# RDS

# variable "database_config" {
#   type = map(object({
#     user_name = string
#     password  = string
#   }))
# }