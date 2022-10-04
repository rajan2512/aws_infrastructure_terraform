resource "aws_security_group" "security_group" {
  for_each = var.security_group_sets


  name                   = each.key
  vpc_id                 = lookup(each.value, "vpc_id", null)
  revoke_rules_on_delete = lookup(each.value, "revoke_rules_on_delete", false)
  tags                   = lookup(each.value, "tags", {})
  dynamic "ingress" {
    for_each = try(each.value["ingress"], [])
    content {
      description     = lookup(ingress.value, "description", null)
      from_port       = lookup(ingress.value, "from_port", null)
      to_port         = lookup(ingress.value, "to_port", null)
      protocol        = lookup(ingress.value, "protocol", null)
      cidr_blocks     = try(ingress.value["cidr_blocks"], null)
      security_groups = try(ingress.value["security_groups"], [])
      self            = lookup(ingress.value, "self", null)
    }
  }
  dynamic "egress" {
    for_each = try(each.value["egress"], null)
    content {
      from_port       = lookup(egress.value, "from_port", null)
      to_port         = lookup(egress.value, "to_port", null)
      protocol        = lookup(egress.value, "protocol", null)
      cidr_blocks     = try(egress.value["cidr_blocks"], null)
      security_groups = try(egress.value["security_groups"], null)
      self            = lookup(egress.value, "self", null)
    }
  }

}
