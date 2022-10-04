variable "allocated_storage" {
  description = "(Required unless a snapshot_identifier or replicate_source_db is provided) The allocated storage in gibibytes. If max_allocated_storage is configured, this argument represents the initial storage allocation and differences from the configuration will be ignored automatically when Storage Autoscaling occurs."
}
variable "auto_minor_version_upgrade" {
  description = "(Optional) Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible."
  default = null
}
variable "backup_retention_period" {
  description = "(Optional) The days to retain backups for. Must be between 0 and 35. Must be greater than 0 if the database is used as a source for a Read Replica."
  default = null
}
variable "backup_window" {
  description = "(Optional) The daily time range (in UTC) during which automated backups are created if they are enabled. Example: 09:46-10:16. Must not overlap with maintenance_window."
  default = null
}
variable "copy_tags_to_snapshot" {
  description = "(Optional, boolean) Copy all Instance tags to snapshots. Default is false."
  default = null
}
variable "maintenance_window" {
  description = "(Optional) The window to perform maintenance in. Syntax: ddd:hh24:mi-ddd:hh24:mi. Eg: Mon:00:00-Mon:03:00."
  default = null
}
variable "db_subnet_group_name" {
  description = " (Optional) Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC, or in EC2 Classic, if available. When working with read replicas, it should be specified only if the source database specifies an instance in another AWS Region."
  default = null
}
variable "multi_az" {
  description = "(Optional) Specifies if the RDS instance is multi-AZ"
  default = null
}
variable "storage_encrypted" {
  description = "(Optional) Specifies whether the DB instance is encrypted. Note that if you are creating a cross-region read replica this field is ignored and you should instead declare kms_key_id with a valid ARN. The default is false if not specified."
  default = null
}
variable "publicly_accessible" {
  description = "(Optional) Bool to control if instance is publicly accessible. Default is false."
  default = null
}
variable "storage_type" {
  description = "(Optional) One of standard (magnetic), gp2 (general purpose SSD), or io1 (provisioned IOPS SSD). The default is io1 if iops is specified, gp2 if not."
  default = null
}
variable "engine" {
  description = "(Required unless a snapshot_identifier or replicate_source_db is provided) The database engine to use. For supported values, see the Engine parameter in API action CreateDBInstance. Note that for Amazon Aurora instances the engine must match the DB cluster's engine'."
  default = null
}
variable "engine_version" {
  description = "(Optional) The engine version to use. If auto_minor_version_upgrade is enabled, you can provide a prefix of the version such as 5.7 (for 5.7.10) and this attribute will ignore differences in the patch version automatically (e.g. 5.7.17)."
  default = null
}
variable "instance_class" {
  description = "(Required) The instance type of the RDS instance."
}
variable "name" {
  description = "(Optional) The name of the database to create when the DB instance is created. If this parameter is not specified, no database is created in the DB instance. "
  default = null
}
variable "username" {
  description = "(Required unless a snapshot_identifier or replicate_source_db is provided) Username for the master DB user."
  default = null
}
variable "password" {
  description = "(Required unless a snapshot_identifier or replicate_source_db is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file."
  default = null
}
variable "parameter_group_name" {
  description = "(Optional) Name of the DB parameter group to associate."
  default = null
}
variable "vpc_security_group_ids" {
  description = "(Optional) List of VPC security groups to associate."
  default = null
}
variable "replicate_source_db" {
  description = "(Optional) ARN of the source database"
  default = null
}
variable "skip_final_snapshot" {
  description = ""
  default = "true"
}
variable "tags" {
  description = "(Optional) A map of tags to assign to the resource."
  default = null
}
