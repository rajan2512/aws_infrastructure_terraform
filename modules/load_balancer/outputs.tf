output "load_balancer_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = aws_lb.main.id
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer we created."
  value       = aws_lb.main.dns_name
}



output "load_balancer_zone_id" {
  description = "The zone id of the load balancer we created."
  value       = aws_lb.main.zone_id
}
