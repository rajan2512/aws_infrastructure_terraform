#output "ids_set" {
#  value = [for o in aws_security_group.default : o.id]
#}
output "ids_map" {
  value = aws_security_group.security_group
}
#output "name" {
#  value = { for k, o in aws_security_group.default : k => o.name }
#}
