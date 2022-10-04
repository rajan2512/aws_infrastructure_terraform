
resource "aws_wafv2_web_acl" "waf-acl" {

  for_each = var.waf_configurations
  name     = each.key
  scope    = each.value["scope"]
  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = try(each.value["rule"], [])
    content {
      name     = lookup(rule.value, "name", null)
      priority = lookup(rule.value, "priority", null)
      override_action {
        none {}
      }
      statement {
        managed_rule_group_statement {
          name        = lookup(rule.value, "managed_rule_name", null)
          vendor_name = lookup(rule.value, "vendor_name", null)
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = lookup(rule.value, "cloudwatch_metrics_enabled", null)
        metric_name                = lookup(rule.value, "metric_name", null)
        sampled_requests_enabled   = lookup(rule.value, "sampled_requests_enabled", null)
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = lookup(each.value, "cloudwatch_metrics_enabled", null)
    metric_name                = lookup(each.value, "metric_name", null)
    sampled_requests_enabled   = lookup(each.value, "sampled_requests_enabled", null)
  }

}

