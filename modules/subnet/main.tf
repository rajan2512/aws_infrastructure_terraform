#########################################
#                 SUBNETS               #
#########################################
resource "aws_subnet" "Subnet" {

  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = var.subnet_name
  }
}
