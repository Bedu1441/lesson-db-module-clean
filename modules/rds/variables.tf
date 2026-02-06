variable "name" {
  type        = string
  description = "Base name for DB resources (used in identifiers/tags)."
}

variable "use_aurora" {
  type        = bool
  description = "If true, creates Aurora cluster + writer instance. If false, creates single RDS instance."
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where DB resources will be created."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for DB Subnet Group (usually private subnets in 2+ AZ)."

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide at least 2 subnet_ids in different AZs for high availability."
  }
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to access the database port (ingress)."
  default     = []
}

variable "allowed_security_group_ids" {
  type        = list(string)
  description = "Security Group IDs allowed to access the database port (ingress)."
  default     = []
}

variable "engine" {
  type        = string
  description = <<EOT
Database engine.
For RDS instance (use_aurora=false): use 'postgres' or 'mysql'
For Aurora (use_aurora=true): use 'aurora-postgresql' or 'aurora-mysql'
EOT

  validation {
    condition = contains(
      ["postgres", "mysql", "aurora-postgresql", "aurora-mysql"],
      var.engine
    )
    error_message = "engine must be one of: postgres, mysql, aurora-postgresql, aurora-mysql."
  }
}

variable "engine_version" {
  type        = string
  description = "Engine version (e.g., '15.4' for postgres, '8.0.35' for mysql, Aurora versions per AWS)."
  default     = ""
}

variable "database_name" {
  type        = string
  description = "Initial database name to create."
  default     = "appdb"
}

variable "master_username" {
  type        = string
  description = "Master username for DB."
  default     = "dbadmin"
}

variable "master_password" {
  type        = string
  description = "Master password for DB. Pass via terraform.tfvars (gitignored) or TF_VAR_master_password."
  sensitive   = true
}

variable "port" {
  type        = number
  description = "DB port. If 0, will default based on engine (5432 for postgres, 3306 for mysql)."
  default     = 0
}

variable "instance_class" {
  type        = string
  description = "Instance class for RDS instance or Aurora writer instance."
  default     = "db.t3.medium"
}

variable "multi_az" {
  type        = bool
  description = "Multi-AZ for RDS instance (ignored for Aurora)."
  default     = false
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in GB for RDS instance (ignored for Aurora)."
  default     = 20
}

variable "storage_type" {
  type        = string
  description = "Storage type for RDS instance (gp2, gp3, io1...). Ignored for Aurora."
  default     = "gp3"
}

variable "storage_encrypted" {
  type        = bool
  description = "Enable storage encryption."
  default     = true
}

variable "kms_key_id" {
  type        = string
  description = "Optional KMS key ID for encryption (empty = default AWS key)."
  default     = ""
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention in days."
  default     = 7
}

variable "preferred_backup_window" {
  type        = string
  description = "Backup window (e.g., 03:00-04:00). Empty = AWS default."
  default     = ""
}

variable "preferred_maintenance_window" {
  type        = string
  description = "Maintenance window (e.g., sun:05:00-sun:06:00). Empty = AWS default."
  default     = ""
}

variable "deletion_protection" {
  type        = bool
  description = "Enable deletion protection."
  default     = true
}

variable "apply_immediately" {
  type        = bool
  description = "Apply changes immediately."
  default     = false
}

variable "publicly_accessible" {
  type        = bool
  description = "Whether DB is publicly accessible (should be false for private DB)."
  default     = false
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on destroy (NOT recommended for prod)."
  default     = true
}

variable "final_snapshot_identifier" {
  type        = string
  description = "Final snapshot identifier (used if skip_final_snapshot=false)."
  default     = ""
}

variable "max_connections" {
  type        = number
  description = "Parameter: max_connections."
  default     = 200
}

variable "log_statement" {
  type        = string
  description = "PostgreSQL only: log_statement (none|ddl|mod|all). For MySQL we will map to general_log."
  default     = "ddl"
}

variable "work_mem" {
  type        = string
  description = "PostgreSQL only: work_mem (e.g., '4096' or '4MB' depending on engine). For MySQL we will map to tmp_table_size."
  default     = "4096"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources."
  default     = {}
}
