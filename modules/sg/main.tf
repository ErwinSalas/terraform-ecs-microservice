
locals {
  # var.ingress_rules is a list of objects. Some rules may have the same name as they belong to the same security group. 
  # To compute the list of security groups required for the solution, distinct_rule_names generates an array with unique
  # security group names by eliminating duplicates.
  distinct_rule_names = distinct([for rule in var.ingress_rules : rule.name])
  sg_groups = { for name in local.distinct_rule_names : name => name }
}

resource "aws_security_group" "security_group" {
  for_each = local.sg_groups
  name        = each.value
  vpc_id      = var.vpc_id
  description = "security group for ${each.value}"
}

resource "aws_security_group_rule" "ingress_rule" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  security_group_id        = aws_security_group.security_group[each.value.name].id
  cidr_blocks              = each.value.name != "external-lb" ? null : each.value.cidr_blocks
  source_security_group_id = each.value.name != "external-lb" ?  aws_security_group.security_group[each.value.source_sg].id : null
}

resource "aws_security_group_rule" "egress_rule" {
  for_each = local.sg_groups

  type              = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group[each.key].id
}