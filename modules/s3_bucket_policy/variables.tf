variable "main_bucket_arn" {
  type        = string
  description = "ARN of the main bucket"
}

variable "replica_bucket_arn" {
  type        = string
  description = "ARN of the replica bucket"
}

variable "replication_policy_name" {
  type        = string
  description = "Name of the replication policy"
}

variable "replication_role_name" {
  type        = string
  description = "Name of the replication role"
}
