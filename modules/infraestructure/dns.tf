resource "aws_service_discovery_private_dns_namespace" "fgms_dns_discovery" {
  name        = var.fargate_private_dns_namespace
  description = "fgms dns discovery"
  vpc         = aws_vpc.main.id
}