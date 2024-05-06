
# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_task_auth_sg" {
  name        = "auth-ecs-tasks-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [var.alb_sg]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id


  # Regla de entrada para permitir el tráfico desde el grupo de seguridad de Fargate
  ingress {
    from_port   = 5432  # Puerto PostgreSQL
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs_task_auth_sg.id]
  }
  # Otras reglas de seguridad si es necesario
}