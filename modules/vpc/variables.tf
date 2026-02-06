variable "name" {
  type        = string
  description = "Base name for VPC resources."
  default     = "lesson-db-vpc"
}

variable "cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones for subnets."
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDR blocks for public subnets (must match number of AZs)."
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnets) == length(var.azs)
    error_message = "public_subnets length must equal azs length."
  }
}

variable "private_subnets" {
  type        = list(string)
  description = "CIDR blocks for private subnets (must match number of AZs)."
  default     = ["10.0.11.0/24", "10.0.12.0/24"]

  validation {
    condition     = length(var.private_subnets) == length(var.azs)
    error_message = "private_subnets length must equal azs length."
  }
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in the VPC."
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in the VPC."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to VPC resources."
  default     = {}
}
