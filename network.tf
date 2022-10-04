locals {
  private_route_tables             = ["PrivateRouteTableA", "PrivateRouteTableB"]
  exported_nat_gateways            = [for nat_gateway in module.create_nat_gateways : nat_gateway]
  exported_private_subnets         = [for private_subnet in module.create_private_subnets : private_subnet]
  exported_db_subnets              = [for db_subnet in module.create_db_subnets : db_subnet]
  exported_public_subnets          = [for public_subnet in module.create_public_subnets : public_subnet]
  enviroment                       = terraform.workspace
  name_sufix                       = local.enviroment == "default" ? "" : "-${local.enviroment}"
  region                           = terraform.workspace == "failover" ? "us-east-1" : "eu-central-1"
  failover                         = terraform.workspace == "failover" ? true : false
  s3_artifact_bucket_name          = "launchpadlambdafunctions"
  s3_failover_artifact_bucket_name = "launchpadfailoverfunctions"


}
# locals {
#   routetables = [{
#     route_table_name  = "PublicRouteTableA"
#     cidr_block        = "0.0.0.0/0"
#     gateway_id        = module.vpc_ig.gateway_id
#   },
#   {
#     route_table_name  = "PublicRouteTableB"
#     cidr_block        = "0.0.0.0/0"
#     gateway_id        = module.vpc_ig.gateway_id
#   }]
# }

module "vpc_ig" {
  source       = "./modules/vpc_ig"
  cidr_block   = "10.0.0.0/16"
  vpc_name     = tomap({ Name = "LaunchpadVPCTerraform" })
  gateway_tags = tomap({ Name = "LaunchpadIgwTerraform" })
}

module "create_public_subnets" {
  source            = "./modules/subnet"
  vpc_id            = module.vpc_ig.vpc_id
  for_each          = { subnet1 : { subnet_name = "PublicSubnetA", cidr_block = "10.0.0.0/24", availability_zone = "${local.region}a" }, subnet2 : { subnet_name = "PublicSubnetB", cidr_block = "10.0.3.0/24", availability_zone = "${local.region}b" } }
  subnet_name       = each.value.subnet_name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
}
module "create_private_subnets" {
  source = "./modules/subnet"
  vpc_id = module.vpc_ig.vpc_id
  for_each = { subnet3 : { subnet_name = "PrivateSubnetA", cidr_block : "10.0.1.0/24", availability_zone = "${local.region}a" },
    subnet4 : { subnet_name = "PrivateSubnetB", cidr_block : "10.0.4.0/24", availability_zone = "${local.region}b" },
  }
  subnet_name       = each.value.subnet_name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
}
module "create_db_subnets" {
  source = "./modules/subnet"
  vpc_id = module.vpc_ig.vpc_id
  for_each = { subnet5 : { subnet_name = "DbSubnetA", cidr_block : "10.0.2.0/24", availability_zone = "${local.region}a" },
  subnet6 : { subnet_name = "DbSubnetB", cidr_block : "10.0.5.0/24", availability_zone = "${local.region}b" } }
  subnet_name       = each.value.subnet_name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
}

module "create_nat_gateways" {
  source           = "./modules/nat"
  for_each         = module.create_public_subnets
  attach_to_vpc    = true
  subnet_id        = each.value.subnet.id
  nat_gateway_name = "GW_${each.value.subnet.id}"
}

module "create_public_route_tables" {
  source = "./modules/route_tables"

  vpc_id           = module.vpc_ig.vpc_id
  route_table_name = "PublicRouteTable"
  cidr_block       = "0.0.0.0/0"
  gateway_id       = module.vpc_ig.gateway_id
  nat_gateway_id   = null
}

module "create_private_route_tables" {
  source = "./modules/route_tables"
  depends_on = [
    module.create_nat_gateways
  ]
  count            = length(local.private_route_tables)
  vpc_id           = module.vpc_ig.vpc_id
  route_table_name = local.private_route_tables[count.index]
  cidr_block       = "0.0.0.0/0"
  gateway_id       = null
  nat_gateway_id   = local.exported_nat_gateways[count.index].nat_gateways.id
}
module "create_public_route_table_associations" {
  source         = "./modules/route_associations"
  for_each       = module.create_public_subnets
  subnet_id      = each.value.subnet.id
  route_table_id = module.create_public_route_tables.route_tables.id
}
module "create_private_route_table_associations" {
  source         = "./modules/route_associations"
  count          = length(local.exported_private_subnets)
  subnet_id      = local.exported_private_subnets[count.index].subnet.id
  route_table_id = module.create_private_route_tables[count.index].route_tables.id
}
# module "create_private_route_table_b" {
#   source = "./modules/route_tables"
#   depends_on = [
#     module.create_nat_gateways
#   ]
#   vpc_id           = module.vpc_ig.id
#   route_table_name = "PrivateRouteTableB"
#   cidr_block       = "0.0.0.0/0"
#   gateway_id       = module.create_nat_gateways.subnet2.nat_gateways.id
# }


#  module "create_private_route_table" {
#   source            = "./modules/route_tables"
#   depends_on = [
#     module.create_nat_gateways
#   ]

#   for_each          = module.create_nat_gateways.*
#   vpc_id            = module.vpc_ig.id
#   tables             = { routetable : {route_table_name = "PrivateRouteTable_A", cidr_block = "0.0.0.0/0" , gateway_id = each.value.id} }
#  }






# module "create_route_tables" {
#   source            = "./modules/route_tables"
#   vpc_id            = module.vpc_ig.id
#   data              = { routetable1 : {route_table_name = "PublicRouteTable",cidr_block:"0.0.0.0/0",gateway_id = module.vpc_ig.g_id},
#                         routetable2 : {route_table_name = "PrivateRouteTableA",cidr_block:"0.0.0.0/0",gateway_id = module.nat.PublicSubnetA.id},
#                         routetable3 : {route_table_name = "PrivateRouteTableB",cidr_block:"0.0.0.0/0",gateway_id = module.nat.PublicSubnetB.id} }

#   associations      = { association1 : {subnet_id = module.nat.PublicSubnetA.id,route_table_id = PublicRouteTable.id},
#                         association2 : {subnet_id = module.nat.PublicSubnetB.id,route_table_id = PublicRouteTable.id},
#                         association3 : {subnet_id = module.nat.PrivateSubnetA.id,route_table_id = PrivateRouteTableA.id},
#                         association4 : {subnet_id = module.nat.PrivateSubnetB.id,route_table_id = PrivateRouteTableB.id}}


# module "create_public_route_tables" {
#   source            = "./modules/route_tables"

#   vpc_id            = module.vpc_ig.id
#   dynamic "tables" {
#     for_each = local.route_tables

#     content {
#       route_table_name  = tables.value.route_table_name
#       cidr_block        = tables.value.cidr_block
#       gateway_id        = tables.value.gateway_id
#     }
#   }
#  }
