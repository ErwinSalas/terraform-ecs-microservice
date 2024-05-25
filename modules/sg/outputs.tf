output "security_group_ids" {
  value = {
    for name, group in aws_security_group.security_group :
    name => group.id
  }
}