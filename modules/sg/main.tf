
locals {
  # var.ingress_rules is a list of objects that contains inbound rules for SGs.
  # Some rules may have the same name as they belong to the same security group. 
  # To compute the list of security groups required for the solution, sg_groups generates an array with unique
  # security group names by eliminating duplicates.
  sg_groups = distinct([for rule in var.ingress_rules : rule.name])
}

resource "aws_security_group" "security_group" {
  for_each = { for name in local.sg_groups : name => name }

  name        = each.key
  vpc_id      = var.vpc_id
  description = "security group for ${each.key}"
}

resource "aws_security_group_rule" "ingress_rule" {
  # Two or more inbound rules might have same name so we use index to generate a map 
  # to simplify data access and manipulation
  for_each = { for index, rule in var.ingress_rules : index => rule }

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  security_group_id        = aws_security_group.security_group[each.value.name].id
  # There is an exception for external-lb, the inbound rule is driven by cidir block not SG id
  cidr_blocks              = each.value.name != "external-lb" ? null : each.value.cidr_blocks
  source_security_group_id = each.value.name != "external-lb" ?  aws_security_group.security_group[each.value.source_sg].id : null
}

resource "aws_security_group_rule" "egress_rule" {
  for_each = aws_security_group.security_group

  type              = "egress"
  from_port   = 0
  to_port     = 0
  # -1 means we allow all the protocols
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = each.value.id
}