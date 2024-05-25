resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "auth-rds-subnet-group"
  description = "RDS subnet group"
  subnet_ids  = var.private_subnets
}

resource "aws_db_instance" "service_db" {
  for_each = var.db_config
  db_name                = each.value.db_name
  allocated_storage   = 20
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  username            = each.value.username
  password            = each.value.password
  skip_final_snapshot = true 

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.security_groups_ids[each.value.security_group]]
}