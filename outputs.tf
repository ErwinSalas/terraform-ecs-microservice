#output "vpc-id" {
#  value = module.vpc.vpc-id
#}
#
#output "private-subnets" {
#  value = module.vpc.private-subnets
#}
#
#output "public-subnets" {
#  value = module.vpc.public-subnets
#}

# output "internal-alb-dns" {
#   value = module.internal_alb.alb-dns
# }

output "external-alb-dns" {
  value = module.public_alb.alb-dns
}
#
#output "internal-alb-target-groups" {
#  value = module.internal-alb.target-groups
#}
#
#output "public-alb-target-groups" {
#  value = module.public-alb.target-groups
#}
#
#output "aws_alb_listener" {
#  value = module.internal-alb.aws_alb_listener
#}

#output "ecr-repositories" {
#  value = module.ecr.repository-services
#}
#
#output "ecs-task-execution-role-arn" {
#  value = module.iam.ecs-task-execution-role-arn
#}

#output "aws_cloudwatch_log_group" {
#  value = module.ecs.aws_cloudwatch_log_group
#}
#
#output "aws_ecs_task_definition" {
#  value = module.ecs.aws_cloudwatch_log_group
#}