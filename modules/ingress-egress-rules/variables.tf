variable "security_groups_ids" {
  type = map(string)
}

variable "ingress_rules" {
  type = map(list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })))
}

variable "egress_rules" {
  type = map(list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })))
}
