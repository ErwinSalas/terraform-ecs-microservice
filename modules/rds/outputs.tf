output "db_urls" {
  value = { for service, config in var.db_config : config.service =>  "postgres://${config.username}:${config.password}@${aws_db_instance.service_db[service].endpoint}/${config.service}"}
}