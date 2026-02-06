output "security_group_id" {
  description = "Security Group ID for DB access."
  value       = aws_security_group.db.id
}

output "db_subnet_group_name" {
  description = "DB Subnet Group name."
  value       = aws_db_subnet_group.this.name
}

output "endpoint" {
  description = "Database endpoint (RDS endpoint or Aurora cluster endpoint)."
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
}

output "reader_endpoint" {
  description = "Aurora reader endpoint (null for non-Aurora)."
  value       = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : null
}

output "port" {
  description = "Database port."
  value       = local.db_port
}

output "database_name" {
  description = "Database name."
  value       = var.database_name
}

output "parameter_group_name" {
  description = "DB parameter group name (for RDS instance; null for Aurora)."
  value       = var.use_aurora ? null : aws_db_parameter_group.this[0].name
}

output "cluster_parameter_group_name" {
  description = "Cluster parameter group name (for Aurora; null for RDS instance)."
  value       = var.use_aurora ? aws_rds_cluster_parameter_group.this[0].name : null
}
