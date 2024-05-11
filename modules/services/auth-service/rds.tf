resource "aws_db_subnet_group" "auth_rds_subnet_group" {
  name        = "auth-rds-subnet-group"
  description = "RDS subnet group"
  subnet_ids  = var.private_subnets
}

resource "aws_db_instance" "auth_db" {
  name                   = "auth"
  allocated_storage         = 20
  engine                    = "postgres"
  instance_class            = "db.t3.micro"
  username                  = "auth_service"
  password                  = "!ExSxExSx020821!"
  skip_final_snapshot       = true               # Habilita la generación del snapshot final

  db_subnet_group_name = aws_db_subnet_group.auth_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id,aws_security_group.ecs_task_auth_sg.id]
}