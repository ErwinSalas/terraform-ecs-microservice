resource "aws_db_subnet_group" "product_rds_subnet_group" {
  name        = "product-rds-subnet-group"
  description = "RDS subnet group"
  subnet_ids  = var.subnet_ids
}

resource "aws_db_instance" "product_db" {
  db_name                   = "product_db"
  allocated_storage         = 20
  engine                    = "postgres"
  instance_class            = "db.t3.micro"
  username                  = "product_service"
  password                  = "!ExSxExSx020821!"
  skip_final_snapshot       = true               # Habilita la generación del snapshot final

  db_subnet_group_name = aws_db_subnet_group.product_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.product_rds_sg.id, aws_security_group.ecs_task_product_sg.id]
}