resource "aws_security_group" "security_group" {
  for_each = { for group in var.groups : group => group }

  name        = each.value
  vpc_id      = var.vpc_id
  description = "security group for ${each.value}"
}