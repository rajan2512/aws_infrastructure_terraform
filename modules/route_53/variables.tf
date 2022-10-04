variable "route53_records" {
  type    = map(any)
  default = {}
}
variable "route53_health_checks" {
  type    = map(any)
  default = {}
}

variable "failure_topic_name" {
  type    = string
  default = false
}
