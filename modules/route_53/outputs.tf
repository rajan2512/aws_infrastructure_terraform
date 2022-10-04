output "route_53_record_id" {
  value = { for k, o in aws_route53_record.route53-record : k => o.id }

}
output "failure_sns_topic_arn" {

  value = try(length(var.route53_health_checks), 0) > 0 ? aws_sns_topic.failure[0].arn : null

}
