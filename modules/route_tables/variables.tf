variable "vpc_id" {
  type = string
}
# variable "tables" {
# }




variable "route_table_name" {
  type = string
}
variable "cidr_block" {
  type = string
}
variable "gateway_id" {
  type = any
}
variable "nat_gateway_id" {
  type = any
}
