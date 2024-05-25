variable "vpc_id" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    name = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    source_sg = string
  }))
}