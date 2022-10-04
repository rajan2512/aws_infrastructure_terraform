variable "main_bucket_id" {
  type        = string
  description = "ID of the main bucket"
}

variable "main_bucket_arn" {
  type        = string
  description = "ARN of the main bucket"
}

variable "replication_role_arn" {
  type        = string
  description = "ARN of the replication role"
}
variable "replication_rule_name" {
  type        = string
  description = "Name of the replication rule"
}
variable "replication_rule_status" {
  type        = string
  description = "Status of the replication rule"
}

variable "delete_marker_replication" {
  type        = string
  description = "Delete marker replication"
}

variable "filter_prefix" {
  type        = string
  description = "Prefix of the filter"
}

variable "replica_bucket_arn" {
  type        = string
  description = "ARN of the replica bucket"
}
variable "storage_class" {
  type        = string
  description = "Storage class of the replica bucket"
}


