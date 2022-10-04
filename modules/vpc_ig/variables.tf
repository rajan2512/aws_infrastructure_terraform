variable "cidr_block" {
  description = "(Required) The CIDR block for the VPC."
}
# variable "enable_dns_hostnames" {
#   description = "(Optional) A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
# }
variable "vpc_name" {
  description = "(Optional) A map of tags to assign to the resource."
}
variable "gateway_tags" {
  description = "(Optional) A map of tags to assign to the resource."
}