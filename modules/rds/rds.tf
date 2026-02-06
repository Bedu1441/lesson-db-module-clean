resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1

  identifier = "${var.name}-db"

  engine         = var.engine
  engine_version = var.engine_version != "" ? var.engine_version : null

  instance_class = var.instance_class
  multi_az       = var.multi_az

  db_name  = var.database_name
  username = var.master_username
  password = var.master_password
  port     = local.db_port

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id != "" ? var.kms_key_id : null

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  parameter_group_name = aws_db_parameter_group.this[0].name

  backup_retention_period = var.backup_retention_period
  backup_window           = var.preferred_backup_window != "" ? var.preferred_backup_window : null

  maintenance_window = var.preferred_maintenance_window != "" ? var.preferred_maintenance_window : null

  deletion_protection = var.deletion_protection
  apply_immediately   = var.apply_immediately
  publicly_accessible = var.publicly_accessible

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = (!var.skip_final_snapshot && var.final_snapshot_identifier != "") ? var.final_snapshot_identifier : null

  tags = merge(var.tags, {
    Name = "${var.name}-db"
  })
}
