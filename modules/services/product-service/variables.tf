variable "app_image" {
  type = string
}

variable "app_port" {
  type = number
}

variable "ecs_cluster_id" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "replicas" {
  type = number
}

variable "health_check_path" {
  type = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "task_execution_role" {
  type = string
}

variable "auto_scale_role" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "alb_sg" {
  type = string
}

variable "container_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

# variable "fgms_dns_discovery_id" {
#   type = string
# }