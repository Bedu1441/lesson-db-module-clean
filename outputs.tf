output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "db_endpoint" {
  description = "DB endpoint (RDS endpoint or Aurora writer endpoint)"
  value       = module.rds.endpoint
}

output "db_port" {
  description = "DB port"
  value       = module.rds.port
}

output "db_sg_id" {
  description = "DB security group ID"
  value       = module.rds.security_group_id
}

output "db_reader_endpoint" {
  description = "Aurora reader endpoint (null for non-Aurora)."
  value       = module.rds.reader_endpoint
}

output "db_subnet_group_name" {
  description = "DB subnet group name."
  value       = module.rds.db_subnet_group_name
}

output "db_parameter_group_name" {
  description = "DB parameter group name (RDS only; null for Aurora)."
  value       = module.rds.parameter_group_name
}

output "db_cluster_parameter_group_name" {
  description = "DB cluster parameter group name (Aurora only; null for RDS)."
  value       = module.rds.cluster_parameter_group_name
}

output "database_name" {
  description = "Database name."
  value       = module.rds.database_name
}
