########################################
#                  VPC                 #
########################################
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  # enable_dns_hostnames = var.enable_dns_hostnames
  tags                 = var.vpc_name

}

########################################
#                   IG                 #
########################################
resource "aws_internet_gateway" "igw" {
  vpc_id               = aws_vpc.main.id

  tags                 = var.gateway_tags
}