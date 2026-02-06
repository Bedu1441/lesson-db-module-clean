resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = "${var.name}-cluster"

  engine         = var.engine
  engine_version = var.engine_version != "" ? var.engine_version : null

  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password

  port = local.db_port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id != "" ? var.kms_key_id : null

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window != "" ? var.preferred_backup_window : null

  preferred_maintenance_window = var.preferred_maintenance_window != "" ? var.preferred_maintenance_window : null

  deletion_protection = var.deletion_protection
  apply_immediately   = var.apply_immediately

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = (!var.skip_final_snapshot && var.final_snapshot_identifier != "") ? var.final_snapshot_identifier : null

  tags = merge(var.tags, {
    Name = "${var.name}-cluster"
  })
}

# Writer instance (single)
resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? 1 : 0

  identifier         = "${var.name}-writer-1"
  cluster_identifier = aws_rds_cluster.this[0].id

  instance_class = var.instance_class
  engine         = var.engine

  db_subnet_group_name = aws_db_subnet_group.this.name
  publicly_accessible  = var.publicly_accessible

  tags = merge(var.tags, {
    Name = "${var.name}-writer-1"
  })
}
