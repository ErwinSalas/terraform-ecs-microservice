output "db_url" {
  value = "postgres://${aws_db_instance.auth_db.username}:${aws_db_instance.auth_db.password}@${aws_db_instance.auth_db.endpoint}/auth"
}