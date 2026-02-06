locals {
  is_aurora   = var.use_aurora
  is_postgres = contains(["postgres", "aurora-postgresql"], var.engine)
  is_mysql    = contains(["mysql", "aurora-mysql"], var.engine)

  default_port = local.is_postgres ? 5432 : 3306
  db_port      = var.port == 0 ? local.default_port : var.port

  # Parameter group family examples:
  # postgres:  postgres15, postgres14 ...
  # mysql:     mysql8.0
  # aurora pg: aurora-postgresql15
  # aurora my: aurora-mysql8.0
  # If engine_version empty, we keep family generic-ish defaults.
  family = (
    local.is_aurora
    ? (local.is_postgres ? "aurora-postgresql15" : "aurora-mysql8.0")
    : (local.is_postgres ? "postgres15" : "mysql8.0")
  )

  # Map the required "three params" to engine-appropriate names.
  # - Postgres: max_connections, log_statement, work_mem
  # - MySQL:    max_connections, general_log (instead of log_statement), tmp_table_size (instead of work_mem)
  effective_params = local.is_postgres ? [
    { name = "max_connections", value = tostring(var.max_connections), apply_method = "pending-reboot" },
    { name = "log_statement", value = var.log_statement, apply_method = "pending-reboot" },
    { name = "work_mem", value = var.work_mem, apply_method = "pending-reboot" },
    ] : [
    { name = "max_connections", value = tostring(var.max_connections), apply_method = "pending-reboot" },
    { name = "general_log", value = "1", apply_method = "pending-reboot" },
    { name = "tmp_table_size", value = var.work_mem, apply_method = "pending-reboot" },
  ]
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-db-subnets"
  })
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db-sg"
  description = "Security group for DB access"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-db-sg"
  })
}

resource "aws_security_group_rule" "ingress_cidr" {
  count             = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.db.id
  from_port         = local.db_port
  to_port           = local.db_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  description       = "Allow DB access from allowed CIDRs"
}

resource "aws_security_group_rule" "ingress_sg" {
  count                    = length(var.allowed_security_group_ids) > 0 ? 1 : 0
  type                     = "ingress"
  security_group_id        = aws_security_group.db.id
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_group_ids[0]
  description              = "Allow DB access from allowed SGs (first SG only)."
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.db.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound"
}

# Parameter group for RDS instance
resource "aws_db_parameter_group" "this" {
  count       = local.is_aurora ? 0 : 1
  name        = "${var.name}-db-params"
  family      = local.family
  description = "DB parameter group for ${var.engine}"

  dynamic "parameter" {
    for_each = local.effective_params
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-db-params"
  })
}

# Parameter group for Aurora cluster
resource "aws_rds_cluster_parameter_group" "this" {
  count       = local.is_aurora ? 1 : 0
  name        = "${var.name}-cluster-params"
  family      = local.family
  description = "Cluster parameter group for ${var.engine}"

  dynamic "parameter" {
    for_each = local.effective_params
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-cluster-params"
  })
}
