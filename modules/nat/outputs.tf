output "nat_gateways" {
  value = aws_nat_gateway.NatGw
  #   value = {
  #   for k, bd in aws_nat_gateway.NatGw : k => bd.id
  #  }
  # value = values(aws_nat_gateway.NatGw).*

}
