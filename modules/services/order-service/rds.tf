resource "aws_db_subnet_group" "order_rds_subnet_group" {
  name        = "order-rds-subnet-group"
  description = "RDS subnet group"
  subnet_ids  = var.subnet_ids
}

resource "aws_db_instance" "order_db" {
  db_name                   = "order_db"
  allocated_storage         = 20
  engine                    = "postgres"
  instance_class            = "db.t3.micro"
  username                  = "order_service"
  password                  = "!ExSxExSx020821!"
  skip_final_snapshot       = true               # Habilita la generación del snapshot final

  db_subnet_group_name = aws_db_subnet_group.order_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.order_rds_sg.id, aws_security_group.ecs_task_order_sg.id]
}