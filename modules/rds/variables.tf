variable "private_subnets" {
  type = list(string)
}

variable "security_groups_ids" {
  type = map(string)
}

variable "db_config" {
  type = map(object({
    password           = string
    username          = string
    db_name          = string
    security_group     =string
    service = string
  }))
}