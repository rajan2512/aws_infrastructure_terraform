
variable "attach_to_vpc" {
  type        = bool
  description = "Attach the NAT gateway to the VPC"
}
# variable "allocation_id" {
#   type = string
# }
variable "subnet_id" {
  type = string
}
variable "nat_gateway_name" {
  type = string
}
