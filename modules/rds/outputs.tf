output "db_subnet_group_name" {
  description = "DB Subnet Group name."
  value       = aws_db_subnet_group.this.name
}

output "reader_endpoint" {
  description = "Aurora reader endpoint (null for non-Aurora)."
  value       = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : null
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

output "endpoint" {
  description = "DB endpoint (RDS endpoint or Aurora writer endpoint)"
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
}

output "port" {
  description = "DB port"
  value       = var.use_aurora ? aws_rds_cluster.this[0].port : aws_db_instance.this[0].port
}

output "security_group_id" {
  description = "DB security group ID"
  value       = aws_security_group.db.id
}
