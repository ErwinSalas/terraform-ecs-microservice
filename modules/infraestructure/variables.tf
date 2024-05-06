# variables.tf
variable "ec2_task_execution_role_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "ecs_auto_scale_role_name" {
  type = string
}

variable "az_count" {
  type = string
}

variable "target_app_port" {
  type = number
}

variable "fargate_cpu" {
  type = number
}

variable "fargate_memory" {
  type = number
}

variable "health_check_path" {
  type = string
}

variable "fargate_private_dns_namespace" {
  type = string
}