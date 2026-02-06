variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "db_password" {
  type        = string
  description = "DB master password (set via terraform.tfvars or TF_VAR_db_password)."
  sensitive   = true
}

variable "use_aurora" {
  type        = bool
  description = "Switch between RDS instance (false) and Aurora cluster (true)."
  default     = false
}

variable "engine" {
  type        = string
  description = "DB engine for the module."
  default     = "postgres"
}
