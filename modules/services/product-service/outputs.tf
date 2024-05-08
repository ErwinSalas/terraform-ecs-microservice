# output "fargate_product_namespace" {
#   value = aws_service_discovery_service.product_discovery_service.name
# }

output "alb_hostname" {
  value = "${aws_alb.product_lb.dns_name}:${var.app_port}"
}