output "waf_acl_arn" {
  # value = aws_wafv2_web_acl.waf-acl[each.key].arn
  value = [for k, o in aws_wafv2_web_acl.waf-acl : o.arn]
}
