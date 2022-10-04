variable "lc_name" {
  description = "Creates a unique name for launch template beginning with the specified prefix"

}

variable "image_id" {
  description = "The EC2 image ID to launch"

}

variable "instance_type" {
  description = "The size of instance to launch"

}

variable "key_name" {
  description = "The key name that should be used for the instance"


}


variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with"

}

variable "enable_monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = true
}
