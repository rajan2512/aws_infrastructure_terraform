output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = aws_lb_target_group.main.name
}

output "arn" {
  value = aws_lb_target_group.main.arn
}
