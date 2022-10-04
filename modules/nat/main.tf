#########################################
#                 NAT GW                #
#########################################
resource "aws_eip" "elastic-ip-address" {
  vpc = var.attach_to_vpc
}

resource "aws_nat_gateway" "NatGw" {
  allocation_id = aws_eip.elastic-ip-address.id
  subnet_id     = var.subnet_id
  tags = {
    Name = var.nat_gateway_name
  }
}