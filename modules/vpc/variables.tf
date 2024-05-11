variable "app_name" {
  type = string
}

variable "env" {
  type = string
}

variable "cidr" {
  type = string
}

variable "az_count" {
  type = number
}

variable "availability_zones" {
  type = list(string)
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets"
}