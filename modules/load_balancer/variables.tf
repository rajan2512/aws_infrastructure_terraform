variable "name" {
  description = "Creates a unique name for the load balancer."
}

variable "load_balancer_type" {
  description = "The type of load balancer to create. Possible values are application or network."
}

variable "internal" {
  description = "The type of load balancer to create. Possible values are application or network."

}
variable "security_groups" {
  description = "The security groups to attach to the load balancer. e.g. [\"sg-edcd9784\",\"sg-edcd9785\"]"

}
variable "subnets" {
  description = "A list of subnets to associate with the load balancer. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"

}
variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle."
}
variable "enable_http2" {
  description = "If true, enables HTTP/2 for the load balancer."
}




