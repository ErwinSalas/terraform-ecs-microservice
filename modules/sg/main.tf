
locals {
    sg_groups = {for rule in var.ingress_rules : rule.name => rule.name }
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
  from_port         = 0
  to_port           = 0
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group[each.key].id
}