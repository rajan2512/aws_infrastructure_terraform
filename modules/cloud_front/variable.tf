variable "cloud_front_certificate_arn" {
  type = string
}
variable "cloud_front_custom_domain_name" {
  type = string
}
variable "cloud_front_log_bucket" {
  type = string
}
variable "cloud_front_target" {
  type = string
}
variable "web_acl_id" {
  default = null
}

