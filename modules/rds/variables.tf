variable "private_subnets" {
  type = list(string)
}

variable "password" {
  type = string
}

variable "username" {
  type = string
}

variable "security_groups_ids" {
  type = list(string)
}