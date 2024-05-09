
resource "aws_security_group_rule" "example_ingress" {
  for_each          = var.ingress_rules

  type              = "ingress"
  from_port         = each.value[0].from_port
  to_port           = each.value[0].to_port
  protocol          = each.value[0].protocol
  security_group_id = var.security_groups_ids[each.key]
  cidr_blocks = var.security_groups_ids[each.key] != null ? null : each.value[0].cidr_blocks
  source_security_group_id = var.security_groups_ids[each.key] != null ?  var.security_groups_ids[each.key] : null
}

# Define las reglas de egreso de forma dinámica
resource "aws_security_group_rule" "example_egress" {
  for_each          = var.egress_rules

  type              = "egress"
  from_port         = each.value[0].from_port
  to_port           = each.value[0].to_port
  protocol          = each.value[0].protocol
  cidr_blocks       = each.value[0].cidr_blocks
  security_group_id = var.security_groups_ids[each.key]
}