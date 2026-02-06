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

variable "engine_version" {
  type        = string
  description = "DB engine version."
  default     = "15.4"
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

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
