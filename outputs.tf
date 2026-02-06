output "db_endpoint" {
  value = module.rds.endpoint
}

output "db_port" {
  value = module.rds.port
}

output "db_sg_id" {
  value = module.rds.security_group_id
}
