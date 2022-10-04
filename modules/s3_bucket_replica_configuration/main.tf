resource "aws_s3_bucket_replication_configuration" "replication" {
  # Must have bucket versioning enabled first

  role   = var.replication_role_arn
  bucket = var.main_bucket_id

  rule {
    id     = var.replication_rule_name   // "replication-rule"
    status = var.replication_rule_status // "Enabled"

    delete_marker_replication {
      status = var.delete_marker_replication // "Disabled"
    }

    filter {
      prefix = var.filter_prefix // ""
    }

    destination {
      bucket        = var.replica_bucket_arn
      storage_class = var.storage_class // "STANDARD"
    }
  }
}
