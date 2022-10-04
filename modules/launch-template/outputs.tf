output "launch_template_name" {
  description = "The name of the launch configuration"
  value       = aws_launch_template.lc_name.name
}
output "launch_template_id" {
  value = aws_launch_template.lc_name.id
}


