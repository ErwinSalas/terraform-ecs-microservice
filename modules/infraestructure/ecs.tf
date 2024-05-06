# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "cb-cluster"
}
