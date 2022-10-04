variable "name" {
  description = "A unique name (a maximum of 64 characters are allowed) used as reference when creating the Elastic File System to ensure idempotent file system creation."
}

variable "encrypted" {
  description = "If true, the file system will be encrypted"

}
variable "private_subnets" {
  type        = list(any)
  description = "A map of private subnets to create the mount targets in."
}

variable "security_groups" {
  description = "A list of security groups to associate with the mount targets."
  type        = list(string)
}

variable "efs_replica_id" {
  description = "The ID of the replica file system."
}

variable "failover" {
  description = "The ID of the primary file system."
}
