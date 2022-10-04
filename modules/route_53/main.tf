

resource "aws_route53_record" "route53-record" {
  for_each        = var.route53_records
  name            = each.key
  allow_overwrite = true
  type            = lookup(each.value, "type", null)
  zone_id         = lookup(each.value, "zone_id", null)
  dynamic "alias" {
    for_each = try(each.value["alias"], [])
    content {
      evaluate_target_health = lookup(alias.value, "evaluate_target_health", null)
      name                   = lookup(alias.value, "name", null)
      zone_id                = lookup(alias.value, "zone_id", null)
    }
  }

}
resource "aws_sns_topic" "failure" {
  count = try(length(var.route53_health_checks), 0) > 0 ? 1 : 0
  name  = var.failure_topic_name
}
resource "aws_cloudwatch_metric_alarm" "metric-alarm" {
  for_each            = var.route53_health_checks
  alarm_name          = lookup(each.value.alarm, "alarm_name", null)
  comparison_operator = lookup(each.value.alarm, "comparison_operator", null)
  evaluation_periods  = lookup(each.value.alarm, "evaluation_periods", null)
  metric_name         = lookup(each.value.alarm, "metric_name", null)
  namespace           = lookup(each.value.alarm, "namespace", null)
  period              = lookup(each.value.alarm, "period", null)
  statistic           = lookup(each.value.alarm, "statistic", null)
  threshold           = lookup(each.value.alarm, "threshold", null)
  actions_enabled     = lookup(each.value.alarm, "actions_enabled", null)
  alarm_actions       = [aws_sns_topic.failure[0].arn]

  dimensions = {
    HealthCheckId = aws_route53_health_check.health-check[each.key].id
  }
}

resource "aws_route53_health_check" "health-check" {
  for_each                        = try(var.route53_health_checks, {})
  fqdn                            = each.key
  port                            = lookup(each.value, "port", null)
  type                            = lookup(each.value, "type", null)
  resource_path                   = lookup(each.value, "resource_path", null)
  failure_threshold               = lookup(each.value, "failure_threshold", null)
  request_interval                = lookup(each.value, "request_interval", null)
  insufficient_data_health_status = lookup(each.value, "insufficient_data_health_status", null)
  # cloudwatch_alarm_name           = aws_cloudwatch_metric_alarm.metric-alarm[each.key].alarm_name
  # cloudwatch_alarm_region         = lookup(each.value.alarm, "cloudwatch_alarm_region", null)
}
