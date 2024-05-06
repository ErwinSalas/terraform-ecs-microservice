variable "app_image" {
    type = string
}

variable "app_port" {
    type = number
}

variable "ecs_cluster_id" {
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

variable "aws_region" {
  type = string
}