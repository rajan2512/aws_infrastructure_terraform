resource "aws_db_instance" "default" {
  allocated_storage          = var.allocated_storage
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  backup_retention_period    = var.backup_retention_period
  backup_window              = var.backup_window
  copy_tags_to_snapshot      = var.copy_tags_to_snapshot
  maintenance_window         = var.maintenance_window
  db_subnet_group_name       = var.db_subnet_group_name
  multi_az                   = var.multi_az
  storage_encrypted          = var.storage_encrypted
  publicly_accessible        = var.publicly_accessible
  storage_type               = var.storage_type
  engine                     = var.engine
  engine_version             = var.engine_version
  instance_class             = var.instance_class
  db_name                    = var.name
  username                   = var.username
  password                   = var.password
  parameter_group_name       = var.parameter_group_name
  vpc_security_group_ids     = var.vpc_security_group_ids
  tags                       = var.tags
  replicate_source_db        = var.replicate_source_db
  skip_final_snapshot        = var.skip_final_snapshot
  
  lifecycle {
    ignore_changes = [
      "replicate_source_db",
    ]
  }
}